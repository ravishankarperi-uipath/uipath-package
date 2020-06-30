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
        setBillingStateWhenCountryNotChinaAustralia();
        AccountDnBAddressService.setAddressFieldsOnInsert(Records);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        AccountDnBAddressService.setAddressFieldsOnUpdate(existingRecords, Records);
    }

    public override void onAfterInsert() {
        QueueableWrapper.enqueue(new AccountSharingRollupQueueable(Records, null));
        QueueableWrapper.enqueue(new AccountAddressQueueable(Records, null));
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {

        shareAccountWithParentOwner(existingRecords);
        createAddressForDnBCompany(existingRecords);
        setContactOwnerToAccountOwner(existingRecords);

    }

    private void shareAccountWithParentOwner(Map<Id, SObject> existingRecords) {
        List<Account> changedAccounts = (List<Account>) this.getChangedRecords(new Set<SObjectField>{
            Account.ParentId
        });
        if (changedAccounts.size() > 0) {
            QueueableWrapper.enqueue(
                new AccountSharingRollupQueueable(changedAccounts, existingRecords)
            );
        }
    }

    private void createAddressForDnBCompany(Map<Id, SObject> existingRecords) {
        List<Account> changedAccounts = (List<Account>) this.getChangedRecords(new Set<SObjectField>{
            Account.DnB_Country__c
        });
        if (changedAccounts.size() > 0) {
            QueueableWrapper.enqueue(
                new AccountDNBCompanyQueueable(changedAccounts, existingRecords)
            );
        }
    }

    private void setContactOwnerToAccountOwner(Map<Id, SObject> existingRecords) {
        List<Account> changedAccounts = (List<Account>) this.getChangedRecords(new Set<SObjectField>{
            Account.OwnerId
        });
        if (changedAccounts.size() > 0) {
            QueueableWrapper.enqueue(
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

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Accounts(sObjectList);
        }
    }
}
