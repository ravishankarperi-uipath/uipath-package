
/**
 * Service to delegate address processing from Domain
 * Tests for this are embedded within the domain tests
 */
public without sharing class AccountDnBAddressService  {


    public static void setAddressFieldsOnInsert(List<Account> accounts) {

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

    public static void deriveBillingCountryFromCode(Account account) {
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

    public static void copyCountryToBillingCountry(Account account) {
        if (
            String.isBlank(account.BillingCountry) &&
                String.isNotBlank(account.Country__c)
            ) {
            account.BillingCountry = account.Country__c;
        }
    }

    public static void setAddressFieldsOnUpdate(Map<Id, SObject> oldAccountMap,
        List<Account> accounts) {

        for (Account account : accounts) {
            Account oldAcc = (Account) oldAccountMap.get(account.Id);
            if (String.isNotBlank(account.DnB_Country__c) && String.isBlank(oldAcc.DnB_Country__c)) {
                copyDnBAddressToStandardAddress(account);
            }

        }
    }

    public static void copyDnBAddressToStandardAddress(Account account) {
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

    public static Boolean isStateSupportedForCountry(String country) {
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

}