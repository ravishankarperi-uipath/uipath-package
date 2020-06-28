

public without sharing class AccountMetadata {

    private static List<String> AvailableCountryStatesCached;

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

}