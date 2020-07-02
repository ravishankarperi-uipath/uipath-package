
public without sharing class AccountTerritoryService {


    public static void deriveTerritoryFields(List<Account> accList) {
        //generate maps of metadata
        list<USA_Industry__mdt> uimList = AccountMetadata.Industries;
        map<string, USA_Industry__mdt> uimMap = new map<string, USA_Industry__mdt>();

        for (USA_Industry__mdt uimTmp : uimList) {
            uimMap.put(uimTmp.Industry__c, uimTmp);
        }

        SObjectIndex usaIndustryIndex = new SObjectIndex(
            new List<String>{ 'Industry__c' }
        )
            .putAll(AccountMetadata.Industries);

        list<USA_States__mdt> usmList = AccountMetadata.States;
        map<string, USA_States__mdt> usmMap = new map<string, USA_States__mdt>();

        for (USA_States__mdt usmTmp : usmList) {
            usmMap.put(usmTmp.Billing_State_Code__c + '-' + usmTmp.Country__c, usmTmp);
        }

        list<String> zipCodeList = new list<String>();

        for (Account accTmp : accList) {
            if (string.isNotBlank(accTmp.BillingPostalCode)) {
                zipCodeList.add(accTmp.BillingPostalCode);
            }
        }

        list<UsaZipCodes__mdt> uzmList = [
            Select Postal_Code__c, Region__c, Area__c, Territory__c
            from UsaZipCodes__mdt
            where Postal_Code__c in :zipCodeList
        ];
        map<string, UsaZipCodes__mdt> uzmMap = new map<string, UsaZipCodes__mdt>();

        for (UsaZipCodes__mdt uzmTmp : uzmList) {
            uzmMap.put(uzmTmp.Postal_Code__c, uzmTmp);
        }

        list<ROW_Country__mdt> rcmList = AccountMetadata.Countries;
        map<string, ROW_Country__mdt> rcmMap = new map<string, ROW_Country__mdt>();

        for (ROW_Country__mdt rcmTmp : rcmList) {
            rcmMap.put(rcmTmp.Country_Code__c, rcmTmp);
        }

        //set account fields
        for (Account accTmp : accList) {

            if (!accTmp.Ignore_Territory_Assignment__c) {
                accTmp.Geo__c = null;
                accTmp.Region__c = null;
                accTmp.Area__c = null;

                if (accTmp.BillingCountryCode != null) {
                    if (accTmp.BillingCountryCode == 'US') {
                        accTmp.Geo__c = 'AMER';

                        if (uimMap.containsKey(accTmp.Industry)) {
                            accTmp.Geo__c = uimMap.get(accTmp.Industry).Region__c;
                            accTmp.Region__c = uimMap.get(accTmp.Industry).Territory__c;
                            accTmp.Area__c = uimMap.get(accTmp.Industry).Area__c;
                        } else if (usmMap.containsKey(accTmp.BillingStateCode + '-' + accTmp.BillingCountryCode)) {
                            accTmp.Geo__c = usmMap.get(accTmp.BillingStateCode + '-' + accTmp.BillingCountryCode).Region__c;
                            accTmp.Region__c = usmMap.get(accTmp.BillingStateCode + '-' + accTmp.BillingCountryCode).Territory__c;
                            accTmp.Area__c = usmMap.get(accTmp.BillingStateCode + '-' + accTmp.BillingCountryCode).Area__c;

                        } else if (uzmMap.containsKey(accTmp.BillingPostalCode)) {
                            accTmp.Geo__c = uzmMap.get(accTmp.BillingPostalCode).Region__c;
                            accTmp.Region__c = uzmMap.get(accTmp.BillingPostalCode).Territory__c;
                            accTmp.Area__c = uzmMap.get(accTmp.BillingPostalCode).Area__c;
                        }
                    } else {
                        if (accTmp.BillingCountryCode == 'JP' || accTmp.BillingCountryCode == 'IN') {
                            if (usmMap.containsKey(accTmp.BillingStateCode + '-' + accTmp.BillingCountryCode)) {
                                accTmp.Geo__c = usmMap.get(accTmp.BillingStateCode + '-' + accTmp.BillingCountryCode).Region__c;
                                accTmp.Region__c = usmMap.get(accTmp.BillingStateCode + '-' + accTmp.BillingCountryCode).Territory__c;

                            } else {
                                if (rcmMap.containsKey(accTmp.BillingCountryCode)) {
                                    accTmp.Geo__c = rcmMap.get(accTmp.BillingCountryCode).Region__c;
                                    accTmp.Region__c = rcmMap.get(accTmp.BillingCountryCode).Territory__c;
                                    accTmp.Area__c = rcmMap.get(accTmp.BillingCountryCode).Area__c;
                                }
                            }
                        } else {
                            if (rcmMap.containsKey(accTmp.BillingCountryCode)) {
                                accTmp.Geo__c = rcmMap.get(accTmp.BillingCountryCode).Region__c;
                                accTmp.Region__c = rcmMap.get(accTmp.BillingCountryCode).Territory__c;
                                accTmp.Area__c = rcmMap.get(accTmp.BillingCountryCode).Area__c;
                            }
                        }
                    }
                }
            }
        }
    }

}