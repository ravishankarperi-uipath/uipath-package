/**
 * sets up Company_Tier__c field on Account
 */
public with sharing class AccountSetCompanyTierQueueable extends AbstractQueueable {
  private final List<SObject> accountsLst;
  private final List<SObject> topAccountsLst;
  private final Map<Id, SObject> oldAccountsMap;

  // Region Specific Sets
  private static Set<String> AMERRegionSpecEnterprise = new Set<String>{
    'Enterprise Tier 1',
    'Enterprise Tier 2',
    'Enterprise Tier 3'
  };
  private static Set<String> AMERRegionSpecVelocity = new Set<String>{
    'Velocity Tier 1',
    'Velocity Tier 2',
    'Velocity Tier 3'
  };
  private static Set<String> IndiaRegionSpecEnterprise = new Set<String>{ 'BPO Accounts', 'India Business' };

  // Ultimate Parent Classification
  private static Set<String> ClassificationAMERIndiaJapan = new Set<String>{ 'Global', 'Enterprise', 'Growth' };
  private static Set<String> ClassificationAPACEMEA = new Set<String>{ 'Global', 'Enterprise' };
  private static Set<String> ClassificationAMER = new Set<String>{ 'Velocity', 'Commercial', 'SMB' };
  private static Set<String> ClassificationAPACEMEAINDIA = new Set<String>{ 'Velocity', 'Commercial' };
  private static Set<String> ClassificationJapan = new Set<String>{ 'Velocity', 'Commercial', 'Inside Sales' };

  // Classificatin Sets
  private static Set<String> ClassificationEnterprise = new Set<String>{ 'Global', 'Enterprise' };
  private static Set<String> ClassificationVelocity = new Set<String>{ 'Velocity' };
  private static Set<String> ClassificationCommercial = new Set<String>{ 'Commercial' };
  private static Set<String> ClassificationSMB = new Set<String>{ 'SMB' };

  // UIPath Sets
  private static Set<String> AMERUiPathProgram = new Set<String>{ 'Strategic AMER', 'GOV' };
  private static Set<String> APACUiPathProgram = new Set<String>{ 'Strategic APAC' };

  // Industry Sets
  private static Set<String> AccountIndustries = new Set<String>{ 'Public Sector', 'Government' };
  private static Set<String> APACEmailDomains = new Set<String>{ 'gov.sg', 'edu.sg', 'gov.au', 'edu.au' };

  public AccountSetCompanyTierQueueable(
    List<SObject> accountsLst,
    List<SObject> topAccountsLst,
    Map<Id, SObject> oldAccountsMap
  ) {
    super('AccountSetCompanyTierQueueable');
    this.accountsLst = accountsLst;
    this.topAccountsLst = topAccountsLst;
    this.oldAccountsMap = oldAccountsMap;
  }

  public override void work() {
    this.setCompanyTier(this.accountsLst, topAccountsLst, oldAccountsMap);
  }

  // ============================================================================
  // Set up Company Tier - after insert / after update
  // ============================================================================
  private void setCompanyTier(List<Account> accountsLst, List<Account> topAccountList, Map<Id, SObject> oldAccountMap) {
    if (oldAccountMap == null) {
      Map<Id, Account> accountsMap = reQueryAccountsWithRelevantFields(accountsLst);
      List<Account> accounts = accountsMap.values();
      for (Account acc : accounts) {
        if (acc.ParentId == null) {
          acc.Company_Tier__c = 'A';
        } else {
          processAccountGeo(acc);
        }
      }
      update accounts;
    } else {
      List<Account> accountsToUpdate = getAllAccountsToUpdate(accountsLst, topAccountList);
      Set<Id> accountsWithOpenOpps = reAccountsWithOpportunity(accountsToUpdate);
      for (Account acc : accountsToUpdate) {
        if (accountsWithOpenOpps.contains(acc.Id) || acc.ParentId == null) {
          acc.Company_Tier__c = 'A';
        } else {
          processAccountGeo(acc);
        }
      }
      update accountsToUpdate;
    }
  }

  private static List<Account> getAllAccountsToUpdate(List<Account> accountsLst, List<Account> topAccountList) {
    List<Account> accountsToUpdate = new List<Account>();
    Map<Id, Account> childrenAccountsToUpdate = new Map<Id, Account>();
    Map<Id, Account> changedAccountsToUpdate = new Map<Id, Account>();

    if (accountsLst != null) {
      changedAccountsToUpdate = reQueryAccountsWithRelevantFields(accountsLst);
      accountsToUpdate = changedAccountsToUpdate.values();
    }
    if (topAccountList != null) {
      childrenAccountsToUpdate = reQueryChildrenAccWithRelevantFields(topAccountList);
      for (Id accId : childrenAccountsToUpdate.keySet()) {
        if (!changedAccountsToUpdate.containsKey(accId)) {
          accountsToUpdate.add(childrenAccountsToUpdate.get(accId));
        }
      }
    }
    return accountsToUpdate;
  }

  private static Set<Id> reAccountsWithOpportunity(List<Account> accountsLst) {
    List<Opportunity> relatedOpps = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE AccountId IN :accountsLst AND StageName != 'Closed/Won' AND StageName != 'Closed/Lost'
    ];
    Set<Id> accountsWithOpenOpps = new Set<Id>();
    for (Opportunity opp : relatedOpps) {
      accountsWithOpenOpps.add(opp.AccountId);
    }
    return accountsWithOpenOpps;
  }

  private static Map<Id, Account> reQueryAccountsWithRelevantFields(List<Account> accountsLst) {
    Map<Id, Account> accounts = new Map<Id, Account>(
      [
        SELECT
          Id,
          ParentId,
          Geo__c,
          Classification__c,
          UiPath_Program__c,
          Region_Specific__c,
          Industry,
          Company_Tier__c,
          Email_Domain__c,
          Ultimate_Parent_Classification__c
        FROM Account
        WHERE Id IN :accountsLst
      ]
    );
    return accounts;
  }

  private static Map<Id, Account> reQueryChildrenAccWithRelevantFields(List<Account> accountsLst) {
    Map<Id, Account> accounts = new Map<Id, Account>(
      [
        SELECT
          Id,
          ParentId,
          Geo__c,
          Classification__c,
          UiPath_Program__c,
          Region_Specific__c,
          Industry,
          Company_Tier__c,
          Email_Domain__c,
          Ultimate_Parent_Classification__c
        FROM Account
        WHERE ParentId IN :accountsLst
      ]
    );
    return accounts;
  }

  private static void processAccountGeo(Account acc) {
    acc.Company_Tier__c = '';
    if (acc.Geo__c == 'AMER')
      processAMERAccount(acc);
    if (acc.Geo__c == 'India')
      processIndiaAccount(acc);
    if (acc.Geo__c == 'APAC')
      processAPACAccount(acc);
    if (acc.Geo__c == 'EMEA')
      processEMEAAccount(acc);
    if (acc.Geo__c == 'Japan')
      processJapanAccount(acc);
  }

  private static void processAMERAccount(Account acc) {
    // Enterprise
    if (
      AMERRegionSpecEnterprise.contains(acc.Region_Specific__c) ||
      ClassificationEnterprise.contains(acc.Classification__c) ||
      AMERUiPathProgram.contains(acc.UiPath_Program__c) ||
      ClassificationAMERIndiaJapan.contains(acc.Ultimate_Parent_Classification__c)
    ) {
      acc.Company_Tier__c = 'A';
    } else {
      // Velocity
      if (
        AMERRegionSpecVelocity.contains(acc.Region_Specific__c) ||
        ClassificationVelocity.contains(acc.Classification__c) ||
        ClassificationAMER.contains(acc.Ultimate_Parent_Classification__c)
      ) {
        acc.Company_Tier__c = 'B';
      }
    }
  }

  private static void processIndiaAccount(Account acc) {
    if (IndiaRegionSpecEnterprise.contains(acc.Region_Specific__c)) {
      // Enterprise
      if (
        ClassificationEnterprise.contains(acc.Classification__c) ||
        ClassificationAMERIndiaJapan.contains(acc.Ultimate_Parent_Classification__c)
      ) {
        acc.Company_Tier__c = 'A';
      } else {
        // Velocity
        if (
          ClassificationCommercial.contains(acc.Classification__c) ||
          ClassificationAPACEMEAINDIA.contains(acc.Ultimate_Parent_Classification__c)
        ) {
          acc.Company_Tier__c = 'B';
        } else {
          if (ClassificationSMB.contains(acc.Ultimate_Parent_Classification__c)) {
            acc.Company_Tier__c = 'C';
          }
        }
      }
    }
  }

  private static void processAPACAccount(Account acc) {
    // Enterprise
    if (
      ClassificationEnterprise.contains(acc.Classification__c) ||
      APACUiPathProgram.contains(acc.UiPath_Program__c) ||
      AccountIndustries.contains(acc.Industry) ||
      APACEmailDomains.contains(acc.Email_Domain__c) ||
      ClassificationAPACEMEA.contains(acc.Ultimate_Parent_Classification__c)
    ) {
      acc.Company_Tier__c = 'A';
    } else {
      // Velocity
      if (
        ClassificationCommercial.contains(acc.Classification__c) ||
        ClassificationAPACEMEAINDIA.contains(acc.Ultimate_Parent_Classification__c)
      ) {
        acc.Company_Tier__c = 'B';
      } else {
        if (
          ClassificationSMB.contains(acc.Classification__c) ||
          ClassificationSMB.contains(acc.Ultimate_Parent_Classification__c)
        ) {
          acc.Company_Tier__c = 'C';
        }
      }
    }
  }

  private static void processEMEAAccount(Account acc) {
    // Enterprise
    if (
      ClassificationEnterprise.contains(acc.Classification__c) ||
      AccountIndustries.contains(acc.Industry) ||
      ClassificationAPACEMEA.contains(acc.Ultimate_Parent_Classification__c)
    ) {
      acc.Company_Tier__c = 'A';
    } else {
      // Velocity
      if (
        ClassificationCommercial.contains(acc.Classification__c) ||
        ClassificationAPACEMEAINDIA.contains(acc.Ultimate_Parent_Classification__c)
      ) {
        acc.Company_Tier__c = 'B';
      } else {
        if (
          ClassificationSMB.contains(acc.Classification__c) ||
          ClassificationSMB.contains(acc.Ultimate_Parent_Classification__c)
        ) {
          acc.Company_Tier__c = 'C';
        }
      }
    }
  }

  private static void processJapanAccount(Account acc) {
    // Enterprise
    if (
      ClassificationEnterprise.contains(acc.Classification__c) ||
      ClassificationAMERIndiaJapan.contains(acc.Ultimate_Parent_Classification__c)
    ) {
      acc.Company_Tier__c = 'A';
    } else {
      // Velocity
      if (
        ClassificationCommercial.contains(acc.Classification__c) ||
        ClassificationJapan.contains(acc.Ultimate_Parent_Classification__c)
      ) {
        acc.Company_Tier__c = 'B';
      } else {
        if (
          ClassificationSMB.contains(acc.Classification__c) ||
          ClassificationSMB.contains(acc.Ultimate_Parent_Classification__c)
        ) {
          acc.Company_Tier__c = 'C';
        }
      }
    }
  }
  public static void setUpCompanyTierInsert(List<Account> accounts) {
    AbstractQueueable.enqueue(new AccountSetCompanyTierQueueable(accounts, null, null));
  }
  /**
   * Loop and set Owner on all contacts to the owner of Account
   * @param existingRecords
   */
  public static void setUpCompanyTierUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.ParentId,
        Account.Region_Specific__c,
        Account.UiPath_Program__c,
        Account.Industry,
        Account.Classification__c,
        Account.Geo__c,
        Account.Email_Domain__c
      },
      accounts,
      existingAccounts
    );
    List<Account> eligibleAccounts = (List<Account>) Collection.of(accounts)
      .filter(Match.field(Account.ParentId).hasValue())
      .filter(hasChanged)
      .asList();

    SObjectPredicate hasChangedClassification = new HasRecordChanged(
      new Set<SObjectField>{ Account.Classification__c },
      accounts,
      existingAccounts
    );
    List<Account> eligibleTopAccounts = (List<Account>) Collection.of(accounts)
      .filter(Match.field(Account.ParentId).equals(null))
      .filter(hasChangedClassification)
      .asList();

    if (eligibleAccounts.size() > 0 || eligibleTopAccounts.size() > 0) {
      AbstractQueueable.enqueue(
        new AccountSetCompanyTierQueueable(eligibleAccounts, eligibleTopAccounts, existingAccounts)
      );
    }
  }
}
