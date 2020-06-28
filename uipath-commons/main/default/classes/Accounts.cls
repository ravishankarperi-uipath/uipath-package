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
        setAddressRelatedFields(null,Records);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        setAddressRelatedFields(existingRecords,Records);
    }

        public override void onAfterInsert() {
        QueueableWrapper.enqueue(new AccountSharingRollupQueueable(Records, null));
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        QueueableWrapper.enqueue(
                new AccountSharingRollupQueueable(Records, existingRecords)
        );
    }


//    onInsert
//    if BillingCountry not already set, copy value from Country__c

    /**
     * @DESCRIPTION: This method will populate address fields when an account is created from D&B or when a D&B company is matched with an existing account
     * @AUTHOR: SV - Slalom Consulting
     */
    private void setAddressRelatedFields(
            Map<Id, SObject> oldAccountMap,
            List<Account> accountList
    ) {
        Map<String, String> codeAndCountryMap = new Map<String, String>();

        if (oldAccountMap == null) {
            codeAndCountryMap= AccountMetadata.CountryCodes;
        }

        for (Account acc : accountList) {
            Account oldAcc = null;
            if (oldAccountMap != null) {
                oldAcc = (Account) oldAccountMap.get(acc.Id);
            } else {
                if (
                        String.IsBlank(acc.BillingCountry) &&
                                String.IsNotBlank(acc.Country__c)
                        ) {
                    acc.BillingCountry = acc.Country__c;
                }

                //on insert only
                if (
                        String.IsBlank(acc.BillingCountry) &&
                                String.IsNotBlank(acc.BillingCountryCode)
                        ) {
                    //In case of lead conversion, country code is available on before insert, but country is not available until after insert
                    //Fix that here, so that we can use country for address logic
                    acc.BillingCountry = codeAndCountryMap.get(acc.BillingCountryCode);
                }
            }

            //If account is created from D&B or account is matched with address, populate the standard address
            if (
                    String.IsNotBlank(acc.DnB_Country__c) &&
                            (oldAcc == null || String.IsBlank(oldAcc.DnB_Country__c))
                    ) {

                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>');
                //Insert only
                if (oldAcc == null) {
                    //Account was created through D&B Hoovers insert scenario
                    acc.Country__c = acc.DnB_Country__c;
                    acc.BillingCountry = acc.DnB_Country__c;
                } else {
                    //Update only
                    //Don't allow D&B matching with company in other country
                    if (acc.DnB_Country__c != acc.Country__c) {
                        acc.addError(
                                error('You cannot select a D&B Company from a different country.', acc)
                        );
                    }
                }

                acc.BillingStreet = acc.DnB_Street__c;
                acc.BillingCity = acc.DnB_City__c;

                if (acc.BillingCountry == 'United States') {
                    acc.DnB_Zip_Postal_Code__c = acc.DnB_Zip_Postal_Code__c.left(5);
                }
                acc.BillingPostalCode = acc.DnB_Zip_Postal_Code__c;

                /*
                            Replicate logic for wf 'Populate State from D&B'
                            Only populate state for supported states, otherwise clear out the D&B state
                         */
                if (
                        AccountMetadata.AvailableCountryStates.Contains(acc.DnB_State_Province__c) &&
                                (acc.BillingCountry == 'United States' ||
                                        acc.BillingCountry == 'China' ||
                                        acc.BillingCountry == 'Australia' ||
                                        acc.BillingCountry == 'Brazil' ||
                                        acc.BillingCountry == 'Canada' ||
                                        acc.BillingCountry == 'United Kingdom' ||
                                        acc.BillingCountry == 'Ireland' ||
                                        acc.BillingCountry == 'India' ||
                                        acc.BillingCountry == 'Italy' ||
                                        acc.BillingCountry == 'Mexico')
                        ) {
                    acc.BillingState = acc.DnB_State_Province__c;
                } else {
                    acc.DnB_State_Province__c = '';
                }

                //Default shipping address to billing address on insert
                acc.ShippingCountry = acc.BillingCountry;
                acc.ShippingState = acc.BillingState;
                acc.ShippingStreet = acc.BillingStreet;
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingPostalCode = acc.BillingPostalCode;
            }

            if (oldAcc == null) {
                if (
                        String.IsBlank(acc.DnB_Country__c) &&
                                String.IsNotBlank(acc.BillingCountry)
                        ) {
                    //Support for pre-golive scenario
                    acc.Country__c = acc.BillingCountry;
                }

                //Default shipping address to billing address on insert
                acc.ShippingCountry = acc.BillingCountry;
                acc.ShippingState = acc.BillingState;
                acc.ShippingStreet = acc.BillingStreet;
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingPostalCode = acc.BillingPostalCode;
            }
        }
    }


    public void updateOpportunityActivity(fflib_SObjectUnitOfWork uow) {
        for (Account acc : (List<Account>) Records) {
            acc.Description = 'Last Opportunity Raised ' + System.today();
            uow.registerDirty(acc);
        }
    }

    public void setBillingStateWhenCountryNotChinaAustralia() {
        for (Account account : (List<Account>) Records) {
            if (!isCountryChinaOrAustralia(account) && (account.State__c != null)) {
                account.BillingState = account.State__c;
            }
        }
    }

    public override void onValidate() {
        for (Account acc : (List<Account>) Records) {
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
