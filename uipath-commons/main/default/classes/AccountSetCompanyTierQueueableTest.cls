@isTest
private class AccountSetCompanyTierQueueableTest {
  private static final string AccountEMEA = 'Test Account EMEA';
  private static final string AccountAMER = 'Test Account AMER';
  private static final string AccountAPAC = 'Test Account APAC';
  private static final string AccountIndia = 'Test Account India';
  private static final string AccountJapan = 'Test Account Japan';
  private static final string NewZealand = 'New Zealand';

  @isTest
  private static void setUpCompanyTierInsert1Test() {
    Id prospectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();

    Account accEMEA = new Account(
      Name = AccountEMEA,
      RecordTypeId = prospectRT,
      Country__c = 'Romania',
      Geo__c = 'EMEA',
      BillingCountry = 'Romania',
      Classification__c = 'SMB',
      AnnualRevenue = 100000,
      Industry = 'Energy',
      Overwrite_Classification__c = true
    );
    insert accEMEA;

    AccountSetCompanyTierQueueable accountSetCompanyTierQueueable = new AccountSetCompanyTierQueueable(
      new List<Account>{ accEMEA },
      null,
      null
    );
    accountSetCompanyTierQueueable.execute(null);
    Account insertedAcc = [SELECT Id, Company_Tier__c FROM Account WHERE Id = :accEMEA.Id];

    System.assertEquals('A', insertedAcc.Company_Tier__c);
  }

  @isTest
  private static void setUpCompanyTierInsert2Test() {
    Id prospectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();

    Account enterpriseParentAcc = new Account(
      Name = 'Parent Account 1',
      RecordTypeId = prospectRT,
      Country__c = 'France',
      Industry = 'Energy',
      Classification__c = 'SMB',
      Overwrite_Classification__c = true
    );
    insert enterpriseParentAcc;

    Account velocityParentAcc = new Account(
      Name = 'Parent Account 2',
      RecordTypeId = prospectRT,
      Country__c = 'Italy',
      Industry = 'Construction',
      Classification__c = 'Velocity',
      Overwrite_Classification__c = true
    );
    insert velocityParentAcc;

    Account sMBParentAcc = new Account(
      Name = 'Parent Account 3',
      RecordTypeId = prospectRT,
      Country__c = 'Germany',
      Industry = 'Communications',
      Classification__c = 'SMB',
      Overwrite_Classification__c = true
    );
    insert sMBParentAcc;

    List<Account> accToInsert = new List<Account>();

    Account accEMEAt1 = new Account(
      Name = AccountEMEA,
      RecordTypeId = prospectRT,
      ParentId = sMBParentAcc.Id,
      Country__c = 'Romania',
      Geo__c = 'EMEA',
      Classification__c = 'SMB',
      Industry = 'Energy',
      Overwrite_Classification__c = true
    );
    accToInsert.add(accEMEAt1);

    Account accAMERt1 = new Account(
      Name = AccountAMER,
      RecordTypeId = prospectRT,
      ParentId = velocityParentAcc.Id,
      Country__c = 'Canada',
      Geo__c = 'AMER',
      BillingCountry = 'Canada',
      Classification__c = 'Enterprise',
      AnnualRevenue = 300000000.00,
      Industry = 'Energy',
      Overwrite_Classification__c = true,
      Region_Specific__c = 'Velocity Tier 1'
    );
    accToInsert.add(accAMERt1);

    Account accIndiat1 = new Account(
      Name = AccountIndia,
      RecordTypeId = prospectRT,
      ParentId = velocityParentAcc.Id,
      Country__c = 'India',
      Geo__c = 'India',
      BillingCountry = 'India',
      Classification__c = 'Commercial',
      AnnualRevenue = 300000000.00,
      Industry = 'Energy',
      Overwrite_Classification__c = true,
      Region_Specific__c = 'BPO Accounts'
    );
    accToInsert.add(accIndiat1);

    Account accJapant1 = new Account(
      Name = AccountJapan,
      RecordTypeId = prospectRT,
      Country__c = 'Japan',
      Geo__c = 'Japan',
      BillingCountry = 'Japan',
      Classification__c = 'Commercial',
      AnnualRevenue = 100000.00,
      Industry = 'Energy',
      Overwrite_Classification__c = true
    );
    accToInsert.add(accJapant1);

    Account accAPACt1 = new Account(
      Name = AccountAPAC,
      RecordTypeId = prospectRT,
      ParentId = sMBParentAcc.Id,
      Country__c = NewZealand,
      Geo__c = 'APAC',
      BillingCountry = NewZealand,
      Classification__c = 'Commercial',
      AnnualRevenue = 30000.00,
      Industry = 'Energy',
      Overwrite_Classification__c = true
    );
    accToInsert.add(accAPACt1);

    insert accToInsert;

    AccountSetCompanyTierQueueable accountSetCompanyTierQueueable = new AccountSetCompanyTierQueueable(
      accToInsert,
      null,
      null
    );
    accountSetCompanyTierQueueable.execute(null);

    List<Account> allAccs = [SELECT Id, Name, Company_Tier__c FROM Account];
    for (Account acc : allAccs) {
      if (acc.Name == AccountAMER) {
        System.assertEquals('B', acc.Company_Tier__c);
      }
      if (acc.Name == AccountIndia) {
        System.assertEquals('B', acc.Company_Tier__c);
      }
      if (acc.Name == AccountAPAC) {
        System.assertEquals('C', acc.Company_Tier__c);
      }
      if (acc.Name == AccountEMEA) {
        System.assertEquals('C', acc.Company_Tier__c);
      }
      if (acc.Name == AccountJapan) {
        System.assertEquals('A', acc.Company_Tier__c);
      }
    }
  }

  @isTest
  private static void setUpCompanyTierUpdateTest() {
    Id prospectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();

    Account parentAccEnterprise = new Account(
      Name = 'Parent Account Enterprise',
      RecordTypeId = prospectRT,
      Country__c = 'France',
      Industry = 'Energy',
      Classification__c = 'Enterprise',
      Overwrite_Classification__c = true
    );
    insert parentAccEnterprise;

    Account parentAccVelocity = new Account(
      Name = 'Parent Account Velocity',
      RecordTypeId = prospectRT,
      Country__c = 'France',
      Industry = 'Energy',
      Classification__c = 'Velocity',
      Overwrite_Classification__c = true
    );
    insert parentAccVelocity;

    Account parentAccSMB = new Account(
      Name = 'Parent Account SMB',
      RecordTypeId = prospectRT,
      Country__c = 'France',
      Industry = 'Energy',
      Classification__c = 'SMB',
      Overwrite_Classification__c = true
    );
    insert parentAccSMB;

    Account parentAccGold = new Account(
      Name = 'Parent Account Gold',
      RecordTypeId = prospectRT,
      Country__c = 'France',
      Industry = 'Energy',
      Classification__c = 'Gold',
      Overwrite_Classification__c = true
    );
    insert parentAccGold;

    List<Account> oldaccToUpdate = new List<Account>();
    List<Account> accToUpdate = new List<Account>();

    Account oldaccEMEA = new Account(
      Name = AccountEMEA,
      RecordTypeId = prospectRT,
      ParentId = parentAccGold.Id,
      Country__c = 'Romania',
      Geo__c = 'EMEA',
      BillingCountry = 'Romania',
      Classification__c = 'SMB',
      AnnualRevenue = 100000,
      Industry = 'Energy',
      Overwrite_Classification__c = true
    );
    oldaccToUpdate.add(oldaccEMEA);

    Account oldaccAMER = new Account(
      Name = AccountAMER,
      RecordTypeId = prospectRT,
      ParentId = parentAccVelocity.Id,
      Country__c = 'Canada',
      Geo__c = 'AMER',
      BillingCountry = 'Canada',
      Classification__c = 'Enterprise',
      AnnualRevenue = 300000000.00,
      Industry = 'Energy',
      Overwrite_Classification__c = true,
      Region_Specific__c = 'Velocity Tier 1'
    );
    oldaccToUpdate.add(oldaccAMER);

    Account oldaccIndia = new Account(
      Name = AccountIndia,
      RecordTypeId = prospectRT,
      ParentId = parentAccVelocity.Id,
      Country__c = 'India',
      Geo__c = 'India',
      BillingCountry = 'India',
      Classification__c = 'Commercial',
      AnnualRevenue = 300000000.00,
      Industry = 'Energy',
      Overwrite_Classification__c = true,
      Region_Specific__c = 'BPO Accounts'
    );
    oldaccToUpdate.add(oldaccIndia);

    Account oldaccJapan = new Account(
      Name = AccountJapan,
      RecordTypeId = prospectRT,
      ParentId = parentAccSMB.Id,
      Country__c = 'Japan',
      Geo__c = 'Japan',
      BillingCountry = 'Japan',
      Classification__c = 'Commercial',
      Overwrite_Classification__c = true,
      Industry = 'Communications'
    );
    oldaccToUpdate.add(oldaccJapan);

    Account oldaccAPAC = new Account(
      Name = AccountAPAC,
      RecordTypeId = prospectRT,
      ParentId = parentAccSMB.Id,
      Country__c = NewZealand,
      Geo__c = 'APAC',
      BillingCountry = NewZealand,
      Classification__c = 'Commercial',
      AnnualRevenue = 30000.00,
      Industry = 'Energy',
      Overwrite_Classification__c = true
    );
    oldaccToUpdate.add(oldaccAPAC);

    insert oldaccToUpdate;

    Map<Id, Account> oldAccounts = new Map<Id, Account>(
      [
        SELECT
          Id,
          Name,
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
        WHERE Id IN :oldaccToUpdate
      ]
    );

    Account newAccEMEA = oldaccEMEA.clone();
    newAccEMEA.Id = oldaccEMEA.Id;
    newAccEMEA.Classification__c = 'Commercial';
    accToUpdate.add(newAccEMEA);

    Account newAccAMER = oldaccAMER.clone();
    newAccAMER.Id = oldaccAMER.Id;
    newAccAMER.ParentId = null;
    accToUpdate.add(newAccAMER);

    Account newAccIndia = oldaccIndia.clone();
    newAccIndia.Id = oldaccIndia.Id;
    newAccIndia.Classification__c = 'Enterprise';
    accToUpdate.add(newAccIndia);

    Account newAccAPAC = oldaccAPAC.clone();
    newAccAPAC.Id = oldaccAPAC.Id;
    newAccAPAC.Classification__c = 'SMB';
    accToUpdate.add(newAccAPAC);

    Account newAccJapan = oldaccJapan.clone();
    newAccJapan.Id = oldaccJapan.Id;
    newAccJapan.Classification__c = 'SMB';
    accToUpdate.add(newAccJapan);

    update accToUpdate;

    AccountSetCompanyTierQueueable accountSetCompanyTierQueueable = new AccountSetCompanyTierQueueable(
      accToUpdate,
      null,
      oldAccounts
    );
    accountSetCompanyTierQueueable.execute(null);

    List<Account> allAcc = [
      SELECT Id, Name, ParentId, Classification__c, Ultimate_Parent_Classification__c, Company_Tier__c
      FROM Account
    ];

    for (Account acc : allAcc) {
      if (acc.Name == AccountEMEA) {
        System.assertEquals('B', acc.Company_Tier__c);
      }
      if (acc.Name == AccountAMER) {
        System.assertEquals('A', acc.Company_Tier__c);
      }
      if (acc.Name == AccountIndia) {
        System.assertEquals('A', acc.Company_Tier__c);
      }
      if (acc.Name == AccountAPAC) {
        System.assertEquals('C', acc.Company_Tier__c);
      }
      if (acc.Name == AccountJapan) {
        System.assertEquals('C', acc.Company_Tier__c);
      }
    }
  }
}
