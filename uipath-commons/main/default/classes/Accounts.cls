public with sharing class Accounts extends fflib_SObjectDomain implements IAccounts {
  public static IAccounts newInstance(List<Account> recordList) {
    return (IAccounts) Application.Domain.newInstance(recordList);
  }

  public static IAccounts newInstance(Set<Id> recordIdSet) {
    return (IAccounts) Application.Domain.newInstance(recordIdSet);
  }

  public Accounts(List<Account> sObjectList) {
    super(sObjectList);
  }

  public override void onBeforeInsert() {
    setFieldsForJapanConvertedLeadOnInsert();
    setBillingStateFromStateOnInsert();
    deriveAddressFieldsOnInsert();
    deriveRegionSpecificFieldsOnInsert();
    deriveClassificationFieldsOnInsert();
    AccountTerritoryService.deriveTerritoryFields(Records);
    deriveSubsidiaryOnInsert();
    deriveRecordTypeOnInsert();
    convertAcademicAccount(Records);
    deriveChannelTierOnInsert();
    deriveDataStewardUserOnInsert();
  }

  public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    deriveAddressFieldsOnUpdate();
    deriveRegionSpecificFieldsOnUpdate();
    deriveClassificationFieldsOnUpdate();
    deriveTerritoryFieldsOnUpdate();
    deriveRecordTypeForExistingAccount();
    convertAcademicAccountOnUpdate();
    deriveDataStewardUserOnUpdate();
    deriveSyncStatusForValidatedAccount();

    //Leave this as the last method in the execution of onBeforeUpdate
    callSyncStatusIntegrationProcess();
  }

  public override void onAfterInsert() {
    //Update contact LeadSource for all Japan converted Leads
    AbstractQueueable.enqueue(new AccountUpdateJapanContactQueueable(Records));

    //For global accounts, grant Opp and Contact Edit access to Top level account owner
    AbstractQueueable.enqueue(new AccountSharingRollupQueueable(Records, null));

    //Insert address record copying from Account. Also set that as Primary Shipping and Billing for the account
    AbstractQueueable.enqueue(new AccountAddressQueueable(Records, null));
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    shareAccountWithParentOwner(existingRecords);
    createAddressForDnBCompany(existingRecords);
    setContactOwnerToAccountOwner(existingRecords);
  }

  /**
   * TODO - this will need additional Test Coverage as the Boomi Fieldset is not in the Package
   * The Boomi Fieldset is dependant on DUNS fields that aren't in the unlocked package
   * This is call to Sync Status Automation process only for the Account where Validation Status = "Validated",
   *               i.e they are Validated by Data Stewards and synced to NetSuite
   */
  private void callSyncStatusIntegrationProcess() {
    List<Account> validatedAccounts = Collection.of(Records)
      .filter(
        Match.field(Account.Validation_Status__c)
          .equals(CommonsConstants.ACC_VALIDATION_STATUS_VALIDATED)
      )
      .asList();

    // Call the SyncStatusAutomation Process to check if the Account Updates can be flagged ready to sync to NetSuite
    if (!validatedAccounts.isEmpty()) {
      IntegrationHandler.syncStatusAutomationProcess(
        ExistingRecords,
        validatedAccounts
      );
    }
  }

  /**
   * Copies D&B Address Fields into Standard Address Fields (Billing and Shipping).
   * For US, only first 5 characters of Postal code is derived Only some countries are allowed to have BillingState set
   */
  private void deriveAddressFieldsOnInsert() {
    Collection.of(Records).mapAll(new AccountMapDnBAddressFunction(false));
  }

  /**
   * Sets Record Type based on Account Business Type
   * If Partner, sets record type to Partner Prospect
   * If Customer, setts record Type to Customer Prospect
   */
  private void deriveRecordTypeOnInsert() {
    Collection.of(Records)
      .mapSome(
        Match.field(Account.Account_Business_Type__c).hasValue(),
        new AccountSetRecordTypeFunction()
      );
  }

  /**
   * On Account Insert, Derives Channel tier based on Account Record Type
   */
  private void deriveChannelTierOnInsert() {
    Collection.of(Records)
      .mapSome(
        Match.field(Account.RecordTypeId).hasValue(),
        new AccountSetChannelTierFunction()
      );
  }

  /**
   * On Account Insert, Uses Custom Metadata to map from Country to Subsidiary
   */
  private void deriveSubsidiaryOnInsert() {
    Map<String, String> countrySubsidiaryMap = AccountMetadata.getCountrySubsidiaryMap();
    Collection.of(Records)
      .mapSome(
        Match.field(Account.Country__c).hasValue(),
        new AccountSetSubsidiaryFunction(countrySubsidiaryMap)
      );
  }


  private void deriveSyncStatusForValidatedAccount() {

    SObjectPredicate haveStatusesChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.Sync_Status__c,
        Account.Validation_Status__c
      },
      this.Records,
      this.ExistingRecords
    );

    Collection.of(Records)
      .filter(haveStatusesChanged)
      .mapAll(new AccountSetSyncStatusFunction(this.ExistingRecords));
  }

  /**
   * Updates record type based on Account Business Type
   */
  private void deriveRecordTypeForExistingAccount() {
    SObjectPredicate hasBusinessTypeChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.Account_Business_Type__c },
      this.Records,
      this.ExistingRecords
    );

    Collection.of(this.Records)
      .filter(hasBusinessTypeChanged)
      .mapAll(new AccountSetRecordTypeFunction());
  }

  /**
   * Update Account Territory fields Geo, Region, Area.
   * Uses Custom Metadata types to derive Territory based on Account Industry and Address fields.
   * For USA => Industry, State and Zipcode are used to map  Territory
   * For India and Japan => State and Country are used to map  Territory
   * For Rest of the world => only country is used to map Territory
   */
  private void deriveTerritoryFieldsOnUpdate() {
    List<Account> changedAccounts = (List<Account>) this.getChangedRecords(
      new Set<SObjectField>{
        Account.BillingCountryCode,
        Account.BillingStateCode,
        Account.BillingPostalCode,
        Account.Industry
      }
    );
    if (!changedAccounts.isEmpty()) {
      AccountTerritoryService.deriveTerritoryFields(changedAccounts);
    }
  }

  /**
   * When Geo is AMER(excluding regions Canada and LATAM), Sets an Account Tier based on the Account’s Revenue and Number of Employees.
   * Enterprise Tier 1/2/3
   * Velocity Tier 1/2/3
   */
  private void deriveRegionSpecificFieldsOnInsert() {
    Collection.of(this.Records)
      .mapAll(new AccountSetRegionSpecificTierFunction());
  }

  /**
   * When Geo is AMER(excluding regions Canada and LATAM), Sets an Account Tier based on the Account’s Revenue and Number of Employees.
   * Enterprise Tier 1/2/3
   * Velocity Tier 1/2/3
   */
  private void deriveRegionSpecificFieldsOnUpdate() {
    SObjectPredicate haveRegionSensitiveFieldsChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.Geo__c,
        Account.Region__c,
        Account.AnnualRevenue,
        Account.NumberOfEmployees
      },
      this.Records,
      this.ExistingRecords
    );

    Collection.of(this.Records)
      .filter(haveRegionSensitiveFieldsChanged)
      .mapAll(new AccountSetRegionSpecificTierFunction());
  }

  /**
   * On Account Insert, Sets Classification to “Velocity” or “Enterprise” or “Commercial“ or “SMB“ based on Account Revenue, Region and Parent Account Classification
   */
  private void deriveClassificationFieldsOnInsert() {
    Collection.of(this.Records).mapAll(new AccountSetClassificationFunction());
  }

  /**
   * On Account Update, Sets Classification to “Velocity” or “Enterprise” or “Commercial“ or “SMB“ based on Account Revenue, Region and Parent Account Classification
   */
  private void deriveClassificationFieldsOnUpdate() {
    SObjectPredicate haveClassificationSensitiveFieldsChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.Geo__c,
        Account.Region__c,
        Account.AnnualRevenue,
        Account.Overwrite_Classification__c,
        Account.Parent_Account_Classification__c,
        Account.RecordTypeId,
        Account.Classification__c
      },
      this.Records,
      this.ExistingRecords
    );

    Collection.of(this.Records)
      .filter(haveClassificationSensitiveFieldsChanged)
      .mapAll(new AccountSetClassificationFunction());
  }

  /**
   * On Account Update, Copies D&B Address Fields into Standard Address Fields (Billing and Shipping).
   * For US, only first 5 characters of Postal code is derived Only some countries are allowed to have BillingState set
   */
  private void deriveAddressFieldsOnUpdate() {
    SObjectPredicate hasCountryChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.DnB_Country__c },
      this.Records,
      this.ExistingRecords
    );

    Collection.of(this.Records)
      .filter(hasCountryChanged)
      .mapAll(new AccountMapDnBAddressFunction(true));
  }

  /**
   * For global accounts, grant Opp and Contact Edit access to Top level account owner
   * @param existingRecords
   */
  private void shareAccountWithParentOwner(Map<Id, SObject> existingRecords) {
    List<Account> changedAccounts = (List<Account>) this.getChangedRecords(
      new Set<SObjectField>{ Account.ParentId }
    );
    if (!changedAccounts.isEmpty()) {
      AbstractQueueable.enqueue(
        new AccountSharingRollupQueueable(changedAccounts, existingRecords)
      );
    }
  }

  /**
   * create an address record for when an account is updated using D&B address
   * @param existingRecords
   */
  private void createAddressForDnBCompany(Map<Id, SObject> existingRecords) {
    List<Account> changedAccounts = (List<Account>) this.getChangedRecords(
      new Set<SObjectField>{ Account.DnB_Country__c }
    );
    if (!changedAccounts.isEmpty()) {
      AbstractQueueable.enqueue(
        new AccountDNBCompanyQueueable(changedAccounts, existingRecords)
      );
    }
  }

  /**
   * Loop and set Owner on all contacts to the owner of Account
   * @param existingRecords
   */
  private void setContactOwnerToAccountOwner(Map<Id, SObject> existingRecords) {
    List<Account> changedAccounts = (List<Account>) this.getChangedRecords(
      new Set<SObjectField>{ Account.OwnerId }
    );
    if (changedAccounts.size() > 0) {
      AbstractQueueable.enqueue(
        new AccountSetContactOwnerQueueable(changedAccounts, existingRecords)
      );
    }
  }

  /**
   * Validates accounts inserted or Updated
   */
  public override void onValidate() {
    Collection.of(Records).mapAll(new AccountValidationFunction(null, this));
  }

  /**
   * Validates accounts that are updated
   * @param existingRecords updated Records
   */
  public override void onValidate(Map<Id, SObject> existingRecords) {
    Collection.of(Records)
      .mapAll(new AccountValidationFunction(existingRecords, this));
  }

  /**
   * Set Billing State to the same value as the Custom State field when new Accounts are created
   */
  private void setBillingStateFromStateOnInsert() {
    for (Account account : (List<Account>) Records) {
      if ((account.State__c != null)) {
        account.BillingState = account.State__c;
      }
    }
  }

  /**
   * Sets fields Geo and Region to ‘Japan’ for Japanese Accounts created via Lead conversion.
   * “Japanese accounts” are when  Country=Japan
   */
  private void setFieldsForJapanConvertedLeadOnInsert() {
    for (Account acc : (List<Account>) Records) {
      if (acc.Country__c == 'Japan' && acc.Created_by_lead_convert__c) {
        acc.Geo__c = 'Japan';
        acc.Region__c = 'Japan';
      }
    }
  }

  /**
   * On Account Update, Converts Academic RT to Customer Prospect RT if Account has open opportunities
   * TODO move this to Opty closed logic instead of reprocessing on Account
   */
  private void convertAcademicAccountOnUpdate() {
    List<Account> changedAccounts = (List<Account>) this.getChangedRecords(
      new Set<SObjectField>{
        Account.RecordTypeId,
        Account.Has_Open_Opportunities__c
      }
    );
    if (!changedAccounts.isEmpty()) {
      convertAcademicAccount(changedAccounts);
    }
  }

  /**
   * Convert Academic RT to Customer Prospect if has open opportunities
   * *Org-cleanup : Process Builder - Academic Alliance Account - Update Record Type
   *  TODO : Send push notification : Academic Alliance
   */
  private void convertAcademicAccount(List<Account> accList) {
    Id academicRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Academic')
      .getRecordTypeId();
    Id customerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Customer_Prospect')
      .getRecordTypeId();

    Collection.of(accList)
      .filter(
        Match.field(Account.RecordTypeId)
          .equals(academicRT)
          .also(Account.Has_Open_Opportunities__c)
          .greaterThan(0)
      )
      .mapAll(
        CopyFields.fromRecord(new Account(RecordTypeId = customerProspectRT))
      );
  }

  /**
   * On Account Insert, Populate Assigned Data Steward field with current user when Data Steward is checked
   */
  private void deriveDataStewardUserOnInsert() {
    Collection.of(Records).mapAll(new AccountSetDataStewardFunction());
  }

  /**
   * On Account Update, Populate Assigned Data Steward field with current user when Data Steward is checked
   */
  private void deriveDataStewardUserOnUpdate() {
    SObjectPredicate hasStewardshipFlagChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.Verified_by_Data_Steward__c },
      this.Records,
      this.ExistingRecords
    );

    Collection.of(Records)
      .filter(hasStewardshipFlagChanged)
      .mapAll(new AccountSetDataStewardFunction());
  }

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new Accounts(sObjectList);
    }
  }
}
