public with sharing class AccountClassificationService {
    
    /**
     * Set classification field on account
     * *ProcessBuilder clean-up:  Account Segmentation - Update Classification 
     */
    public static void setClassificationField(List<Account> recordList){

        Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id customerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Prospect').getRecordTypeId();
        Id partnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Id partnerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Prospect').getRecordTypeId();
        Id prospectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();

        for(Account acc : recordList){

            if( acc.RecordTypeId == customerRT ||
                acc.RecordTypeId == customerProspectRT ||
                acc.RecordTypeId == partnerRT ||
                acc.RecordTypeId == prospectRT ){

                // AMER (wo Canada & LATAM) - ENTERPRISE
                if(
                    acc.Geo__c == 'AMER' &&
                    acc.Region__c != 'Canada' &&
                    acc.Region__c != 'LATAM' &&
                    acc.AnnualRevenue >= 1000000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Enterprise';             
                }
                // AMER (wo Canada & LATAM) - Velocity
                else if(
                    acc.Geo__c == 'AMER' &&
                    acc.Region__c != 'Canada' &&
                    acc.Region__c != 'LATAM' &&
                    acc.AnnualRevenue < 1000000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Velocity';             
                }
                // AMER (Canada) - Enterprise
                else if(
                    acc.Geo__c == 'AMER' &&
                    acc.Region__c == 'Canada' &&
                    acc.AnnualRevenue >= 200000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Enterprise';             
                }
                // AMER (Canada) - Velocity
                else if(
                    acc.Geo__c == 'AMER' &&
                    acc.Region__c == 'Canada' &&
                    acc.AnnualRevenue < 200000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Velocity';             
                }
                // AMER (LATAM) - Enterprise
                else if(
                    acc.Geo__c == 'AMER' &&
                    acc.Region__c == 'LATAM' &&
                    acc.AnnualRevenue >= 150000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Enterprise';             
                }
                // AMER (LATAM) - Velocity
                else if(
                    acc.Geo__c == 'AMER' &&
                    acc.Region__c == 'LATAM' &&
                    acc.AnnualRevenue < 150000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Velocity';             
                }
                // EMEA - Enterprise
                else if(
                    acc.Geo__c == 'EMEA' &&
                    acc.AnnualRevenue >= 1000000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Enterprise';             
                }
                // EMEA - Commercial
                else if(
                    acc.Geo__c == 'EMEA' &&
                    acc.AnnualRevenue >= 250000000.00 &&
                    acc.AnnualRevenue < 1000000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Commercial';             
                }
                // EMEA - SMB
                else if(
                    acc.Geo__c == 'EMEA' &&
                    acc.AnnualRevenue < 250000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'SMB';             
                }
                // INDIA - Commercial
                else if(
                    acc.Geo__c == 'India' &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Classification__c != 'Global' &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Commercial';             
                }
                // APAC - Enterprise
                else if(
                    acc.Geo__c == 'APAC' &&
                    acc.AnnualRevenue >= 1000000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Enterprise';             
                }
                // APAC - Commercial
                else if(
                    acc.Geo__c == 'APAC' &&
                    acc.AnnualRevenue >= 250000000.00 &&
                    acc.AnnualRevenue < 1000000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'Commercial';             
                }
                // APAC - SMB
                else if(
                    acc.Geo__c == 'APAC' &&
                    acc.AnnualRevenue < 250000000.00 &&
                    acc.Overwrite_Classification__c == false &&
                    acc.Parent_Account_Classification__c != 'Global' 
                ){
                    acc.Classification__c = 'SMB';             
                }
            }
        }
    }

}
