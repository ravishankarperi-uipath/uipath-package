

public without sharing class AccountMetadata {

    private static List<String> AvailableCountryStatesCached;
    private static List<USA_Industry__mdt> IndustriesCached;
    private static List<USA_States__mdt> StatesCached;
    private static List<ROW_Country__mdt> CountriesCached;

    public static List<String> AvailableCountryStates {
        get {
            if (AvailableCountryStatesCached == null) {
                AvailableCountryStatesCached = new List<String>();

                Schema.DescribeFieldResult stateResult = Address__c.State__c.getDescribe();
                List<Schema.PicklistEntry> statePLE = stateResult.getPicklistValues();

                for (Schema.PicklistEntry entry : statePLE) {
                    AvailableCountryStatesCached.add(entry.getValue());
                }
            }
            return AvailableCountryStatesCached;
        }
    }


    private static Map<String, String> CountryCodesCached;

    public static Map<String, String> CountryCodes {
        get {
            if (CountryCodesCached == null) {
                CountryCodesCached = new Map<String, String>();

                //Retrieve Country Codes
                Schema.DescribeFieldResult countryCodeResult = User.Countrycode.getDescribe();
                List<Schema.PicklistEntry> countryPLE = countryCodeResult.getPicklistValues();
                for (Schema.PicklistEntry entry : countryPLE) {
                    CountryCodesCached.put(entry.getValue(), entry.getLabel());
                }
            }
            return CountryCodesCached;
        }
    }


    public static List<USA_Industry__mdt> Industries {
        get {
            if (IndustriesCached == null) {
                IndustriesCached = [Select Region__c, Industry__c, Area__c, Territory__c from USA_Industry__mdt];
            }
            return IndustriesCached;
        }
    }

    public static list<USA_States__mdt> States {
        get {
            if (StatesCached == null) {
                StatesCached = [Select Label, DeveloperName, Region__c, Billing_State_Code__c, Area__c, Territory__c, Country__c from USA_States__mdt];
            }
            return StatesCached;
        }
    }
    public static list<ROW_Country__mdt> Countries {
        get {
            if (CountriesCached == null) {
                CountriesCached = [Select Country_Code__c, Region__c, Area__c, Territory__c from ROW_Country__mdt];
            }
            return CountriesCached;
        }
    }

    public static SObjectIndex getCountriesByCountryCode() {
        SObjectIndex countriesByCountryCode = new SObjectIndex(
            new List<String>{
                'Country_Code__c'
            }
        )
            .putAll(AccountMetadata.Countries);
        return countriesByCountryCode;
    }

    public static SObjectIndex getUsaZipCodesForAccounts(List<Account> accounts) {
        List<String> zipCodes = Collection.of(accounts)
            .pluckStrings(Account.BillingPostalCode);

        List<UsaZipCodes__mdt> usaZipCodes = [
            SELECT Postal_Code__c, Region__c, Area__c, Territory__c
            FROM UsaZipCodes__mdt
            WHERE Postal_Code__c IN :zipCodes
        ];
        SObjectIndex usaZipCodesIndex = new SObjectIndex(
            new List<String>{
                'Postal_Code__c'
            }
        )
            .putAll(usaZipCodes);
        return usaZipCodesIndex;
    }

    public static SObjectIndex getStatesByCodeAndCountry() {
        SObjectIndex statesByCodeAndCountry = new SObjectIndex(
            new List<String>{
                'Billing_State_Code__c', 'Country__c'
            }
        )
            .putAll(AccountMetadata.States);
        return statesByCodeAndCountry;
    }

    public static SObjectIndex getUsaIndustriesByName() {
        SObjectIndex usaIndustriesByName = new SObjectIndex(
            new List<String>{
                'Industry__c'
            }
        )
            .putAll(AccountMetadata.Industries);
        return usaIndustriesByName;
    }


    public static ROW_Country__mdt getAccountCountry(SObjectIndex countriesByCountryCode, Account acc) {
        ROW_Country__mdt accountCountry = (ROW_Country__mdt) countriesByCountryCode.get(
            new ROW_Country__mdt(Country_Code__c = acc.BillingCountryCode)
        );
        return accountCountry;
    }

    public static UsaZipCodes__mdt getAccountZipcode(SObjectIndex usaZipCodesIndex, Account acc) {
        UsaZipCodes__mdt accountZipcode = (UsaZipCodes__mdt) usaZipCodesIndex.get(
            new UsaZipCodes__mdt(Postal_Code__c = acc.BillingPostalCode)
        );
        return accountZipcode;
    }

    public static USA_States__mdt getAccountState(SObjectIndex usaStatesByCodeAndCountry, Account acc) {
        USA_States__mdt accountState = (USA_States__mdt) usaStatesByCodeAndCountry.get(
            new USA_States__mdt(
                Billing_State_Code__c = acc.BillingStateCode,
                Country__c = acc.BillingCountryCode
            )
        );
        return accountState;
    }

    public static USA_Industry__mdt getAccountIndustry(SObjectIndex usaIndustriesByName, Account acc) {
        USA_Industry__mdt accountIndustry = (USA_Industry__mdt) (usaIndustriesByName.get(
            acc.Industry
        ));
        return accountIndustry;
    }


}