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
      if (acc.Overwrite_Classification__c == false) {
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
      } else {
        if (acc.Parent_Account_Classification__c == 'Global' && acc.Classification__c != 'Global')
          processGlobalAccount(acc);
      }
    }

    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  private static void processAMERAccount(Account acc) {
    // AMER (wo Canada & LATAM) - ENTERPRISE

    if (acc.Region__c != 'Canada' && acc.Region__c != 'LATAM' && acc.AnnualRevenue >= 1000000000.00) {
      acc.Classification__c = 'Enterprise';
    } else if (acc.Region__c != 'Canada' && acc.Region__c != 'LATAM' && acc.AnnualRevenue < 1000000000.00) {
      // AMER (wo Canada & LATAM) - Velocity
      acc.Classification__c = 'Velocity';
    } else if (acc.Region__c == 'Canada' && acc.AnnualRevenue >= 200000000.00) {
      // AMER (Canada) - Enterprise
      acc.Classification__c = 'Enterprise';
    } else if (acc.Region__c == 'Canada' && acc.AnnualRevenue < 200000000.00) {
      // AMER (Canada) - Velocity
      acc.Classification__c = 'Velocity';
    } else if (acc.Region__c == 'LATAM' && acc.AnnualRevenue >= 150000000.00) {
      // AMER (LATAM) - Enterprise
      acc.Classification__c = 'Enterprise';
    } else if (acc.Region__c == 'LATAM' && acc.AnnualRevenue < 150000000.00) {
      // AMER (LATAM) - Velocity
      acc.Classification__c = 'Velocity';
    } else if (acc.AnnualRevenue == null) {
      acc.Classification__c = '';
    }
  }

  private static void processEMEAAccount(Account acc) {
    // EMEA - Enterprise

    if (acc.AnnualRevenue >= 1000000000.00) {
      acc.Classification__c = 'Enterprise';
    } else if (acc.AnnualRevenue >= 250000000.00 && acc.AnnualRevenue < 1000000000.00) {
      acc.Classification__c = 'Commercial';
    } else if (acc.AnnualRevenue < 250000000.00) {
      acc.Classification__c = 'SMB';
    } else if (acc.AnnualRevenue == null) {
      acc.Classification__c = '';
    }
  }

  private static void processIndiaAccount(Account acc) {
    // INDIA - Commercial
    acc.Classification__c = 'Commercial';
  }

  private static void processAPACAccount(Account acc) {
    // APAC - Enterprise
    if (acc.AnnualRevenue == null) {
      acc.Classification__c = '';
    } else if (acc.AnnualRevenue >= 1000000000.00) {
      acc.Classification__c = 'Enterprise';
    } else if (acc.AnnualRevenue >= 250000000.00 && acc.AnnualRevenue < 1000000000.00) {
      acc.Classification__c = 'Commercial';
    } else if (acc.AnnualRevenue < 250000000.00) {
      acc.Classification__c = 'SMB';
    }
  }

  private static void processGlobalAccount(Account acc) {
    // Global by Parent
    acc.Classification__c = 'Global';
  }

  /**
   * On Account Insert, Sets Classification to “Velocity” or “Enterprise” or “Commercial“ or “SMB“ based on Account Revenue, Region and Parent Account Classification
   */
  public static void deriveClassificationFieldsOnInsert(List<Account> records) {
    Collection.of(records).mapAll(new AccountSetClassificationFunction());
  }

  /**
   * On Account Update, Sets Classification to “Velocity” or “Enterprise” or “Commercial“ or “SMB“ based on Account Revenue, Region and Parent Account Classification
   */
  public static void deriveClassificationFieldsOnUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate haveClassificationSensitiveFieldsChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.Geo__c,
        Account.Region__c,
        Account.AnnualRevenue,
        Account.Overwrite_Classification__c,
        Account.Parent_Account_Classification__c,
        Account.RecordTypeId,
        Account.Classification__c
      },
      accounts,
      existingAccounts
    );

    Collection.of(accounts)
      .filter(haveClassificationSensitiveFieldsChanged)
      .mapAll(new AccountSetClassificationFunction());
  }
}
