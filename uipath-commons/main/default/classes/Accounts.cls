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
        setAddressFieldsOnInsert(Records);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        setAddressFieldsOnUpdate(existingRecords, Records);
    }

    public override void onAfterInsert() {

        QueueableWrapper.enqueue(new AccountSharingRollupQueueable(Records, null));
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        QueueableWrapper.enqueue(
            new AccountSharingRollupQueueable(Records, existingRecords)
        );
    }

    private void setAddressFieldsOnInsert(List<Account> accounts) {

        for (Account account : accounts) {

            copyCountryToBillingCountry(account);
            deriveBillingCountryFromCode(account);

            if (String.isNotBlank(account.DnB_Country__c)) {
                //These 2 fields are only set on insert
                account.Country__c = account.DnB_Country__c;
                account.BillingCountry = account.DnB_Country__c;

                copyDnBAddressToStandardAddress(account);
            }
        }
    }

    private void deriveBillingCountryFromCode(Account account) {
        Map<String, String> codeAndCountryMap = AccountMetadata.CountryCodes;

        if (
            String.isBlank(account.BillingCountry) &&
                String.isNotBlank(account.BillingCountryCode)
            ) {
            //In case of lead conversion, country code is available on before insert, but country is not available until after insert
            //Fix that here, so that we can use country for address logic
            account.BillingCountry = codeAndCountryMap.get(account.BillingCountryCode);
        }
    }

    private void copyCountryToBillingCountry(Account account) {
        if (
            String.isBlank(account.BillingCountry) &&
                String.isNotBlank(account.Country__c)
            ) {
            account.BillingCountry = account.Country__c;
        }
    }

    private void setAddressFieldsOnUpdate(Map<Id, SObject> oldAccountMap,
        List<Account> accounts) {

        for (Account account : accounts) {
            Account oldAcc = (Account) oldAccountMap.get(account.Id);
            if (String.isNotBlank(account.DnB_Country__c) && String.isBlank(oldAcc.DnB_Country__c)) {
                if (account.DnB_Country__c != account.Country__c) {
                    account.addError(
                        error('You cannot select a D&B Company from a different country.', account)
                    );
                }
                copyDnBAddressToStandardAddress(account);
            }

        }
    }

    private void copyDnBAddressToStandardAddress(Account account) {
        account.BillingStreet = account.DnB_Street__c;
        account.BillingCity = account.DnB_City__c;

        if (account.BillingCountry == 'United States') {
            account.DnB_Zip_Postal_Code__c = account.DnB_Zip_Postal_Code__c.left(5);
        }
        account.BillingPostalCode = account.DnB_Zip_Postal_Code__c;

        if (
            AccountMetadata.AvailableCountryStates.Contains(account.DnB_State_Province__c) &&
                (isStateSupportedForCountry(account.BillingCountry))
            ) {
            account.BillingState = account.DnB_State_Province__c;
        } else {
            account.DnB_State_Province__c = '';
        }

        //Default shipping address to billing address on insert
        account.ShippingCountry = account.BillingCountry;
        account.ShippingState = account.BillingState;
        account.ShippingStreet = account.BillingStreet;
        account.ShippingCity = account.BillingCity;
        account.ShippingPostalCode = account.BillingPostalCode;
    }



    public Boolean isStateSupportedForCountry(String country) {
        return country == 'United States' ||
            country == 'China' ||
            country == 'Australia' ||
            country == 'Brazil' ||
            country == 'Canada' ||
            country == 'United Kingdom' ||
            country == 'Ireland' ||
            country == 'India' ||
            country == 'Italy' ||
            country == 'Mexico';
    }


    private void setBillingStateWhenCountryNotChinaAustralia() {
        for (Account account : (List<Account>) Records) {
            if (!isCountryChinaOrAustralia(account) && (account.State__c != null)) {
                account.BillingState = account.State__c;
            }
        }
    }

    public override void onValidate() {
        for (Account acc : (List<Account>) Records) {
            validateStatePopulatedForChinaAustralia(acc);
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
