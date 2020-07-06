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
        setFieldsForJapanConvertedLead();
        setBillingStateWhenCountryNotChinaAustralia();
        AccountDnBAddressService.deriveAddressFieldsOnInsert(Records);
        deriveRegionSpecificFieldsOnInsert();
        deriveClassificationFieldsOnInsert();
        AccountTerritoryService.deriveTerritoryFields(Records);
        deriveSubsidiary(Records);
        deriveRecordType(Records);
    }

    private void deriveRecordType(List<Account> accounts) {

        Collection.of(accounts)
            .mapSome(Match.field(Account.Account_Business_Type__c).hasValue(), new AccountSetRecordTypeFunction());

    }

    private void deriveSubsidiary(List<Account> accounts) {

        Map<String, String> countrySubsidiaryMap = AccountMetadata.getCountrySubsidiaryMap();
        Collection.of(accounts)
            .mapSome(Match.field(Account.Country__c).hasValue(), new AccountSetSubsidiaryFunction(countrySubsidiaryMap));

    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        deriveAddressFieldsOnUpdate();
        deriveRegionSpecificFieldsOnUpdate();
        deriveClassificationFieldsOnUpdate();
        deriveTerritoryFieldsOnUpdate();
        deriveSyncStatusForValidatedAccount(existingRecords);
        deriveRecordTypeForExistingAccount(existingRecords);
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

    private void deriveSyncStatusForValidatedAccount(Map<Id, SObject> existingRecords) {
        List<Account> changedAccounts = (List<Account>) this.getChangedRecords(
            new Set<SObjectField>{
                Account.Sync_Status__c,
                Account.Validation_Status__c
            }
        );

        Collection.of(changedAccounts).mapAll(new AccountSetSyncStatusFunction(existingRecords));

    }

    private void deriveRecordTypeForExistingAccount(Map<Id, SObject> existingRecords) {
        List<Account> changedAccounts = (List<Account>) this.getChangedRecords(
            new Set<SObjectField>{
                Account.Account_Business_Type__c
            }
        );

        Collection.of(changedAccounts).mapAll(new AccountSetRecordTypeFunction());

    }

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

    private void deriveRegionSpecificFieldsOnInsert() {
        AccountRegionSpecificTierService.setRegionSpecificField(Records);
    }

    private void deriveRegionSpecificFieldsOnUpdate() {
        List<Account> regionSpecificAccounts = (List<Account>) this.getChangedRecords(
            new Set<SObjectField>{
                Account.Geo__c,
                Account.Region__c,
                Account.AnnualRevenue,
                Account.NumberOfEmployees
            }
        );
        AccountRegionSpecificTierService.setRegionSpecificField(regionSpecificAccounts);
    }

    private void deriveClassificationFieldsOnInsert() {
        AccountClassificationService.setClassificationField(Records);
    }

    private void deriveClassificationFieldsOnUpdate() {
        List<Account> classifyAccounts = (List<Account>) this.getChangedRecords(new Set<SObjectField>{
            Account.Geo__c,
            Account.Region__c,
            Account.AnnualRevenue,
            Account.Overwrite_Classification__c,
            Account.Parent_Account_Classification__c,
            Account.RecordTypeId,
            Account.Classification__c
        });
        if (!classifyAccounts.isEmpty()) {
            AccountClassificationService.setClassificationField(classifyAccounts);
        }
    }

    private void deriveAddressFieldsOnUpdate() {
        List<Account> dnbCountryModifiedAccounts = (List<Account>) this.getChangedRecords(
            new Set<SObjectField>{
                Account.DnB_Country__c
            }
        );
        if (!dnbCountryModifiedAccounts.isEmpty()) {
            AccountDnBAddressService.deriveAddressFieldsOnUpdate(dnbCountryModifiedAccounts);
        }
    }

    /**
     * For global accounts, grant Opp and Contact Edit access to Top level account owner
     * @param existingRecords
     */
    private void shareAccountWithParentOwner(Map<Id, SObject> existingRecords) {
        List<Account> changedAccounts = (List<Account>) this.getChangedRecords(
            new Set<SObjectField>{
                Account.ParentId
            }
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
            new Set<SObjectField>{
                Account.DnB_Country__c
            }
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
            new Set<SObjectField>{
                Account.OwnerId
            }
        );
        if (changedAccounts.size() > 0) {
            AbstractQueueable.enqueue(
                new AccountSetContactOwnerQueueable(changedAccounts, existingRecords)
            );
        }
    }

    public override void onValidate() {
        for (Account acc : (List<Account>) Records) {
            validateStatePopulatedForChinaAustralia(acc);
        }
    }

    public override void onValidate(Map<Id, SObject> existingRecords) {
        for (Account account : (List<Account>) Records) {
            Account oldAccount = (Account) existingRecords.get(account.Id);
            validateIfDnBCountryChanged(account, oldAccount);
        }
    }

    private void validateIfDnBCountryChanged(Account account, Account oldAcc) {
        if (
            String.isNotBlank(account.DnB_Country__c) &&
                String.isBlank(oldAcc.DnB_Country__c)
            ) {
            if (account.DnB_Country__c != account.Country__c) {
                account.addError(
                    error(
                        'You cannot select a D&B Company from a different country.',
                        account
                    )
                );
            }
        }
    }

    private void setBillingStateWhenCountryNotChinaAustralia() {
        for (Account account : (List<Account>) Records) {
            if (!isCountryChinaOrAustralia(account) && (account.State__c != null)) {
                account.BillingState = account.State__c;
            }
        }
    }

    private void validateStatePopulatedForChinaAustralia(Account acc) {
        if (isCountryChinaOrAustralia(acc) && acc.State__c == null) {
            acc.State__c.addError(
                error(
                    'State is required if Country is ' + acc.Country__c,
                    acc,
                    Account.State__c
                )
            );
        }
    }

    private Boolean isCountryChinaOrAustralia(Account acc) {
        return (acc.Country__c == 'China' || acc.Country__c == 'Australia');
    }

    /**
     * Set Geo and Region for Japan converted Leads
     * *Org-cleanup : Process Builder - Conversion aid, Geo and Region
     */
    private void setFieldsForJapanConvertedLead(){
        for(Account acc : (List<Account>) Records){
            if(acc.Country__c == 'Japan' && acc.Created_by_lead_convert__c){
                acc.Geo__c = 'Japan';
                acc.Region__c = 'Japan';
            }
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Accounts(sObjectList);
        }
    }

}
