public without sharing class AccountTerritoryService {
    public static void deriveTerritoryFields(List<Account> accounts) {

        SObjectIndex usaIndustriesByName = getUsaIndustriesByName();
        SObjectIndex usaStatesByCodeAndCountry = getUsaStatesByCodeAndCountry();
        SObjectIndex usaZipCodesIndex=getUsaZipCodesIndex(accounts);

        List<ROW_Country__mdt> rcmList = AccountMetadata.Countries;
        Map<string, ROW_Country__mdt> rcmMap = new Map<string, ROW_Country__mdt>();

        for (ROW_Country__mdt rcmTmp : rcmList) {
            rcmMap.put(rcmTmp.Country_Code__c, rcmTmp);
        }

        //set account fields
        for (Account accTmp : accounts) {
            if (!accTmp.Ignore_Territory_Assignment__c) {
                accTmp.Geo__c = null;
                accTmp.Region__c = null;
                accTmp.Area__c = null;

                USA_Industry__mdt accountIndustry = (USA_Industry__mdt) (usaIndustriesByName.get(
                    accTmp.Industry
                ));

                if (accTmp.BillingCountryCode != null) {
                    USA_States__mdt accountState = (USA_States__mdt) usaStatesByCodeAndCountry.get(
                        new USA_States__mdt(
                            Billing_State_Code__c = accTmp.BillingStateCode,
                            Country__c = accTmp.BillingCountryCode
                        )
                    );

                    UsaZipCodes__mdt accountZipcode = (UsaZipCodes__mdt) usaZipCodesIndex.get(
                        new UsaZipCodes__mdt(
                            Postal_Code__c = accTmp.BillingPostalCode
                        )
                    );

                    if (accTmp.BillingCountryCode == 'US') {
                        accTmp.Geo__c = 'AMER';

                        if (accountIndustry != null) {
                            accTmp.Geo__c = accountIndustry.Region__c;
                            accTmp.Region__c = accountIndustry.Territory__c;
                            accTmp.Area__c = accountIndustry.Area__c;
                        } else if (accountState != null) {
                            accTmp.Geo__c = accountState.Region__c;
                            accTmp.Region__c = accountState.Territory__c;
                            accTmp.Area__c = accountState.Area__c;
                        } else if (accountZipcode != null) {
                            accTmp.Geo__c = accountZipcode.Region__c;
                            accTmp.Region__c = accountZipcode
                                .Territory__c;
                            accTmp.Area__c = accountZipcode.Area__c;
                        }
                    } else {
                        if (
                            accTmp.BillingCountryCode == 'JP' ||
                                accTmp.BillingCountryCode == 'IN'
                            ) {
                            if (accountState != null) {
                                accTmp.Geo__c = accountState.Region__c;
                                accTmp.Region__c = accountState.Territory__c;
                            } else {
                                if (rcmMap.containsKey(accTmp.BillingCountryCode)) {
                                    accTmp.Geo__c = rcmMap.get(accTmp.BillingCountryCode)
                                        .Region__c;
                                    accTmp.Region__c = rcmMap.get(accTmp.BillingCountryCode)
                                        .Territory__c;
                                    accTmp.Area__c = rcmMap.get(accTmp.BillingCountryCode)
                                        .Area__c;
                                }
                            }
                        } else {
                            if (rcmMap.containsKey(accTmp.BillingCountryCode)) {
                                accTmp.Geo__c = rcmMap.get(accTmp.BillingCountryCode).Region__c;
                                accTmp.Region__c = rcmMap.get(accTmp.BillingCountryCode)
                                    .Territory__c;
                                accTmp.Area__c = rcmMap.get(accTmp.BillingCountryCode).Area__c;
                            }
                        }
                    }
                }
            }
        }
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
