/**
 * Responsibility: Account Domain Class
 * Mostly just delegates work to Mapped Functions or to Async Queueables
 */
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
    AccountJapanConvertedLeadFunction.setGeoFields(Records);
    AccountBillingStateFromStateFunction.copyStateToBillingState(Records);
    AccountMapDnBAddressFunction.deriveAddressFieldsOnInsert(Records);
    AccountSetRegionSpecificTierFunction.deriveRegionSpecificFieldsOnInsert(
      Records
    );
    AccountSetClassificationFunction.deriveClassificationFieldsOnInsert(
      Records
    );
    AccountTerritoryService.deriveTerritoryFields(Records);
    AccountSetSubsidiaryFunction.deriveSubsidiaryOnInsert(Records);
    AccountSetRecordTypeFunction.deriveRecordTypeOnInsert(Records);
    AccountConvertAcademic.convertAcademicAccount(Records);
    AccountSetChannelTierFunction.deriveChannelTierOnInsert(Records);
    AccountSetDataStewardFunction.deriveDataStewardUserOnInsert(Records);
    AccountSetLegalEntityNameFunction.deriveLegalEntityNameOnInsert(Records);
    AccountSetStateFunction.deriveStateOnInsert(Records);
    AccountSetClassificationGlobalFunction.deriveRecordTypeOnInsert(Records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    AccountMapDnBAddressFunction.deriveAddressFieldsOnUpdate(
      Records,
      existingRecords
    );
    AccountSetRegionSpecificTierFunction.deriveRegionSpecificFieldsOnUpdate(
      Records,
      existingRecords
    );
    AccountSetClassificationFunction.deriveClassificationFieldsOnUpdate(
      Records,
      existingRecords
    );
    AccountTerritoryService.deriveTerritoryFieldsOnUpdate(
      Records,
      existingRecords
    );
    AccountSetRecordTypeFunction.deriveRecordTypeForExistingAccount(
      Records,
      existingRecords
    );
    AccountConvertAcademic.convertAcademicAccountOnUpdate(
      Records,
      existingRecords
    );
    AccountSetDataStewardFunction.deriveDataStewardUserOnUpdate(
      Records,
      existingRecords
    );
    AccountSetSyncStatusFunction.deriveSyncStatusForValidatedAccount(
      Records,
      existingRecords
    );
    AccountSetStateFunction.deriveStateOnUpdate(Records, existingRecords);
    //Leave this as the last method in the execution of onBeforeUpdate
    IntegrationHandler.callAccountSyncStatusIntegrationProcess(
      Records,
      existingRecords
    );
  }

  public override void onAfterInsert() {
    //Update contact LeadSource for all Japan converted Leads
    AbstractQueueable.enqueue(new AccountUpdateJapanContactQueueable(Records));
    //For global accounts, grant Opp and Contact Edit access to Top level account owner
    AbstractQueueable.enqueue(new AccountSharingRollupQueueable(Records, null));
    //Insert address record copying from Account. Also set that as Primary Shipping and Billing for the account
    AbstractQueueable.enqueue(new AccountAddressQueueable(Records, null));
    AbstractQueueable.enqueue(new AccountSetGAMEmailQueueable(Records, null));
    AccountDnBSyncQueueable.deriveDnBFieldsOnInsert(Records);
    AccountSharingLeadOwnerQueueable.shareAccount(Records);
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    AccountSharingRollupQueueable.shareAccountWithParentOwner(
      Records,
      existingRecords
    );
    AccountDNBCompanyQueueable.createAddressForDnBCompany(
      Records,
      existingRecords
    );
    AccountSetContactOwnerQueueable.setContactOwnerToAccountOwner(
      Records,
      existingRecords
    );
    AccountSetGAMEmailQueueable.setGAMEmailOnGlobalAccounts(
      Records,
      existingRecords
    );
    AccountDnBSyncQueueable.deriveDnBFieldsOnUpdate(Records, existingRecords);
    ZinfiSyncContactWithAccount.zinfiSyncAccountOnUpdate(existingRecords);
    LicensingApiDispatch.licensingApiSyncAccountOnUpdate(Records);
    AccountClassificationGlobalQueueable.setClassificationToGlobal(
      Records,
      existingRecords
    );
    AccountSharingLeadOwnerQueueable.shareAccountOnUpdate(
      Records,
      existingRecords
    );
  }

  public override void onAfterDelete() {
    ZinfiSyncOnline.zinfiSyncAccountOnDelete(Records);
    LicensingApiDispatch.licensingApiSyncAccountOnDelete(Records);
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

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new Accounts(sObjectList);
    }
  }
}
