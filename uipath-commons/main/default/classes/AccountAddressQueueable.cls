/**
 * TODO REWRITE
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 */
public with sharing class AccountAddressQueueable extends QueueableWrapper {
    private final List<SObject> accountsLst;
    private final Map<Id, SObject> oldAccountsMap;

    public AccountAddressQueueable(
            List<SObject> accountsLst,
            Map<Id, SObject> oldAccountsMap
    ) {
        super('AccountAddressQueueable');
        this.accountsLst = accountsLst;
        this.oldAccountsMap = oldAccountsMap;
    }

    public override void work() {
        this.createAddress(this.accountsLst);
    }

    /**
     * TODO REWRITE
     * @DESCRIPTION: This method will create an address record with the country set based on the account country, on account creation.
     * @AUTHOR: SV - Slalom Consulting
     */
    private void createAddress(List<Account> accountList) {
        List<Address__c> addressList = new List<Address__c>();

        List<String> AvailableCountryStates = new List<String>();

        Schema.DescribeFieldResult stateResult = Address__c.State__c.getDescribe();
        List<Schema.PicklistEntry> statePLE = stateResult.getPicklistValues();
        for (Schema.PicklistEntry entry : statePLE) {
            AvailableCountryStates.add(entry.getValue());
        }

        for (Account acc : accountList) {
            Address__c address = new Address__c();
            address.Account__c = acc.Id;
            address.Primary_Billing__c = true;
            address.Primary_Shipping__c = true;
            address.Created_From_Account__c = true;

            //Account was created through D&B Hoovers
            if (acc.DnB_Country__c != null) {
            address.D_B_Address__c = true;
            address.Country__c = acc.DnB_Country__c;

            //D&B street is 255 characters. On address object we have street 1 (150 characters) and street 2 (105 characters)
            if (String.IsNotBlank(acc.DnB_Street__c)) {
                address.Street_Line_1__c = acc.DnB_Street__c.left(150);
                if (acc.DnB_Street__c.length() > 150) {
                address.Street_Line_2__c = acc.DnB_Street__c.substring(
                    150,
                    acc.DnB_Street__c.length()
                );
                }
            }
            address.City__c = acc.DnB_City__c;
            address.Zip_Postal_Code__c = acc.DnB_Zip_Postal_Code__c;

            if (AvailableCountryStates.Contains(acc.DnB_State_Province__c)) {
                address.State__c = acc.DnB_State_Province__c;
            }

            address.RecordTypeId = Utilities.getRecordTypeId(
                Constants.ADDRESS_RECORD_TYPE_LOCKDOWN,
                'Address__c'
            );
            } else {
            //Not created through D&B Hoovers

            // The following below is necessary in the interim period, where we move to production, but before the changes are rolled out to users
            // Country__c should be available on account, but some test classes are failing because they only set billing country code on creation.
            // Because of that, billing country is not available during before insert and Country__c can't be populated accordingly.
            //We have to prevent that address.Country__c is populated with an empty value
            if (String.IsNotBlank(acc.Country__c)) {
                address.Country__c = acc.Country__c;
                // =================================================
                // complete Address State added from new State field
                if (String.IsNotBlank(acc.State__c))
                address.State__c = acc.State__c;
            } else {
                address.Country__c = acc.BillingCountry;
            }

            //Account might be created through lead conversion. Pick up any lead address details that might be available.
            if (String.IsNotBlank(acc.BillingCountry)) {
                //Lead street is 255 characters. On address we have street 1 (150 characters) and street 2 (105 characters)
                if (String.IsNotBlank(acc.BillingStreet)) {
                address.Street_Line_1__c = acc.BillingStreet.left(150);
                if (acc.BillingStreet.length() > 150) {
                    address.Street_Line_2__c = acc.BillingStreet.substring(
                    150,
                    acc.BillingStreet.length()
                    );
                }
                }
                address.City__c = acc.BillingCity;
                address.Zip_Postal_Code__c = acc.BillingPostalCode;
                // ==================================================================================================
                // complete Address State added from billing address completed on account insert from new field State
                address.State__c = acc.BillingState;
            }
            }
            addressList.add(address);
        }

        insert addressList;
    }
}