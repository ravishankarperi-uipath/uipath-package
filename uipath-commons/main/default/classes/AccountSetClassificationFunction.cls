public with sharing class AccountSetClassificationFunction implements SObjectToSObjectFunction {
  private static Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Customer')
    .getRecordTypeId();
  private static Id customerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Customer_Prospect')
    .getRecordTypeId();
  private static Id partnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Partner')
    .getRecordTypeId();
  private static Id partnerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Partner_Prospect')
    .getRecordTypeId();
  private static Id prospectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Prospect')
    .getRecordTypeId();

  /**
   * Set classification field on account
   * *ProcessBuilder clean-up:  Account Segmentation - Update Classification
   */
  public SObject apply(Account acc) {
    if (
      acc.RecordTypeId == customerRT ||
      acc.RecordTypeId == customerProspectRT ||
      acc.RecordTypeId == partnerRT ||
      acc.RecordTypeId == partnerProspectRT ||
      acc.RecordTypeId == prospectRT
    ) {
      // AMER
      if (acc.Geo__c == 'AMER') {
        processAMERAccount(acc);
      } else if (acc.Geo__c == 'EMEA') {
        // EMEA
        processEMEAAccount(acc);
      } else if (acc.Geo__c == 'India') {
        // India
        processIndiaAccount(acc);
      } else if (acc.Geo__c == 'APAC') {
        // APAC
        processAPACAccount(acc);
      }
    }

    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  private static void processAMERAccount(Account acc) {
    // AMER (wo Canada & LATAM) - ENTERPRISE
    if (
      acc.Region__c != 'Canada' &&
      acc.Region__c != 'LATAM' &&
      acc.AnnualRevenue >= 1000000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      acc.Classification__c = 'Enterprise';
    } else if (
      acc.Region__c != 'Canada' &&
      acc.Region__c != 'LATAM' &&
      acc.AnnualRevenue < 1000000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // AMER (wo Canada & LATAM) - Velocity
      acc.Classification__c = 'Velocity';
    } else if (
      acc.Region__c == 'Canada' &&
      acc.AnnualRevenue >= 200000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // AMER (Canada) - Enterprise
      acc.Classification__c = 'Enterprise';
    } else if (
      acc.Region__c == 'Canada' &&
      acc.AnnualRevenue < 200000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // AMER (Canada) - Velocity
      acc.Classification__c = 'Velocity';
    } else if (
      acc.Region__c == 'LATAM' &&
      acc.AnnualRevenue >= 150000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // AMER (LATAM) - Enterprise
      acc.Classification__c = 'Enterprise';
    } else if (
      acc.Region__c == 'LATAM' &&
      acc.AnnualRevenue < 150000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // AMER (LATAM) - Velocity
      acc.Classification__c = 'Velocity';
    }
  }

  private static void processEMEAAccount(Account acc) {
    // EMEA - Enterprise
    if (
      acc.AnnualRevenue >= 1000000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      acc.Classification__c = 'Enterprise';
    } else if (
      acc.AnnualRevenue >= 250000000.00 &&
      acc.AnnualRevenue < 1000000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // EMEA - Commercial
      acc.Classification__c = 'Commercial';
    } else if (
      acc.AnnualRevenue < 250000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // EMEA - SMB
      acc.Classification__c = 'SMB';
    }
  }

  private static void processIndiaAccount(Account acc) {
    // INDIA - Commercial
    if (
      acc.Overwrite_Classification__c == false &&
      acc.Classification__c != 'Global' &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      acc.Classification__c = 'Commercial';
    }
  }

  private static void processAPACAccount(Account acc) {
    // APAC - Enterprise
    if (
      acc.AnnualRevenue >= 1000000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      acc.Classification__c = 'Enterprise';
    } else if (
      acc.AnnualRevenue >= 250000000.00 &&
      acc.AnnualRevenue < 1000000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // APAC - Commercial
      acc.Classification__c = 'Commercial';
    } else if (
      acc.AnnualRevenue < 250000000.00 &&
      acc.Overwrite_Classification__c == false &&
      acc.Parent_Account_Classification__c != 'Global'
    ) {
      // APAC - SMB
      acc.Classification__c = 'SMB';
    }
  }
}
