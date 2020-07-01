

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

}