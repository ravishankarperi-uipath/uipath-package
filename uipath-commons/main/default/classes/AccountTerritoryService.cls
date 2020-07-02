public without sharing class AccountTerritoryService {
    public static void deriveTerritoryFields(List<Account> accounts) {

        SObjectIndex usaIndustriesByName = getUsaIndustriesByName();
        SObjectIndex usaStatesByCodeAndCountry = getUsaStatesByCodeAndCountry();
        SObjectIndex usaZipCodesIndex=getUsaZipCodesIndex(accounts);
        SObjectIndex countriesByCountryCode = getCountriesByCountryCode();

        for (Account acc : accounts) {

            if (!acc.Ignore_Territory_Assignment__c) {
                acc.Geo__c = null;
                acc.Region__c = null;
                acc.Area__c = null;

                USA_Industry__mdt accountIndustry = (USA_Industry__mdt) (usaIndustriesByName.get(
                    acc.Industry
                ));

                if (acc.BillingCountryCode != null) {
                    USA_States__mdt accountState = (USA_States__mdt) usaStatesByCodeAndCountry.get(
                        new USA_States__mdt(
                            Billing_State_Code__c = acc.BillingStateCode,
                            Country__c = acc.BillingCountryCode
                        )
                    );

                    UsaZipCodes__mdt accountZipcode = (UsaZipCodes__mdt) usaZipCodesIndex.get(
                        new UsaZipCodes__mdt(
                            Postal_Code__c = acc.BillingPostalCode
                        )
                    );

                    ROW_Country__mdt accountCountry = (ROW_Country__mdt) countriesByCountryCode.get(
                        new ROW_Country__mdt(
                            Country_Code__c = acc.BillingCountryCode
                        )
                    );

                    if (acc.BillingCountryCode == 'US') {
                        acc.Geo__c = 'AMER';

                        if (accountIndustry != null) {
                            acc.Geo__c = accountIndustry.Region__c;
                            acc.Region__c = accountIndustry.Territory__c;
                            acc.Area__c = accountIndustry.Area__c;
                        } else if (accountState != null) {
                            acc.Geo__c = accountState.Region__c;
                            acc.Region__c = accountState.Territory__c;
                            acc.Area__c = accountState.Area__c;
                        } else if (accountZipcode != null) {
                            acc.Geo__c = accountZipcode.Region__c;
                            acc.Region__c = accountZipcode
                                .Territory__c;
                            acc.Area__c = accountZipcode.Area__c;
                        }
                    } else {
                        if (
                            acc.BillingCountryCode == 'JP' ||
                                acc.BillingCountryCode == 'IN'
                            ) {
                            if (accountState != null) {
                                acc.Geo__c = accountState.Region__c;
                                acc.Region__c = accountState.Territory__c;
                            } else {
                                if (accountCountry!=null) {
                                    acc.Geo__c = accountCountry
                                        .Region__c;
                                    acc.Region__c = accountCountry
                                        .Territory__c;
                                    acc.Area__c = accountCountry
                                        .Area__c;
                                }
                            }
                        } else {
                            if (accountCountry!=null) {
                                acc.Geo__c = accountCountry.Region__c;
                                acc.Region__c = accountCountry
                                    .Territory__c;
                                acc.Area__c = accountCountry.Area__c;
                            }
                        }
                    }
                }
            }
        }
    }

    private static SObjectIndex getCountriesByCountryCode() {
        SObjectIndex countriesByCountryCode = new SObjectIndex(
            new List<String>{
                'Country_Code__c'
            }
        )
            .putAll(AccountMetadata.Countries);
        return countriesByCountryCode;
    }

    private static SObjectIndex getUsaZipCodesIndex(List<Account> accounts) {

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
        ).putAll(usaZipCodes);
        return usaZipCodesIndex;
    }

    private static SObjectIndex getUsaStatesByCodeAndCountry() {
        SObjectIndex usaStatesByCodeAndCountry = new SObjectIndex(
            new List<String>{
                'Billing_State_Code__c', 'Country__c'
            }
        )
            .putAll(AccountMetadata.States);
        return usaStatesByCodeAndCountry;
    }

    private static SObjectIndex getUsaIndustriesByName() {
        SObjectIndex usaIndustriesByName = new SObjectIndex(
            new List<String>{
                'Industry__c'
            }
        )
            .putAll(AccountMetadata.Industries);
        return usaIndustriesByName;
    }
}
