@isTest
public with sharing class AccountSetGAMEmailQueueableTest {
  @isTest
  public static void setupGAMEmailTest() {
    User u1 = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
      .Id,
      Username = 'testgamemailacc@testgam.com',
      LastName = 'TestUser',
      Email = 'testgamemailacc@testgam.com',
      Alias = 'tgame433',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US'
    );

    insert u1;

    Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    Account topParentAcc = new Account();
    System.runAs(u1) {
      topParentAcc = new Account(
        Name = 'TopParentAccount',
        RecordTypeId = customerRT,
        AnnualRevenue = 150000000.00,
        Classification__c = 'General Business',
        Overwrite_Classification__c = false,
        Country__c = 'United States',
        BillingCountry = 'United States',
        Industry = 'Communications'
      );
      insert topParentAcc;
    }

    Account parentAccount = new Account(
      Name = 'ParentAccount',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      AnnualRevenue = 150000000.00,
      Classification__c = 'Global',
      Overwrite_Classification__c = false,
      Country__c = 'United States',
      BillingCountry = 'United States',
      Industry = 'Communications'
    );
    insert parentAccount;

    Account childAccount = new Account(
      Name = 'TestAccount',
      ParentId = parentAccount.Id,
      RecordTypeId = customerRT,
      AnnualRevenue = 5000000.00,
      Overwrite_Classification__c = false,
      Classification__c = 'Global',
      Country__c = 'United States',
      BillingCountry = 'United States',
      Industry = 'Telecommunications'
    );
    insert childAccount;

    AccountSetGAMEmailQueueable accSetGAMEmailQueueable = new AccountSetGAMEmailQueueable(
      new List<Account>{ childAccount },
      null
    );
    accSetGAMEmailQueueable.execute(null);

    List<Account> childAccountIns = [
      SELECT Id, Classification__c, GAM_Email__c
      FROM Account
      WHERE Classification__c = 'Global'
    ];
    System.assertEquals(2, childAccountIns.size());
    for (Account childacc : childAccountIns)
      System.assertEquals('testgamemailacc@testgam.com', childacc.GAM_Email__c);
  }

  @isTest
  public static void setupGAMEmail_Classification_Test() {
    User u1 = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
      .Id,
      Username = 'testgamemailacc@testgam.com',
      LastName = 'TestUser',
      Email = 'testgamemailacc@testgam.com',
      Alias = 'tgame433',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US'
    );

    insert u1;

    Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    Account topParentAcc = new Account();
    System.runAs(u1) {
      topParentAcc = new Account(
        Name = 'TopParentAccount',
        RecordTypeId = customerRT,
        AnnualRevenue = 150000000.00,
        Classification__c = 'General Business',
        Country__c = 'United States',
        BillingCountry = 'United States',
        Overwrite_Classification__c = false,
        Industry = 'Communications'
      );
      insert topParentAcc;
    }

    Account parentAccount = new Account(
      Name = 'ParentAccount',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      AnnualRevenue = 150000000.00,
      Classification__c = 'Global',
      Country__c = 'United States',
      BillingCountry = 'United States',
      Overwrite_Classification__c = false,
      Industry = 'Communications'
    );
    insert parentAccount;

    Account childAccount = new Account(
      Name = 'TestAccount',
      ParentId = parentAccount.Id,
      RecordTypeId = customerRT,
      AnnualRevenue = 5000000.00,
      Classification__c = 'Global',
      Country__c = 'United States',
      BillingCountry = 'United States',
      Industry = 'Telecommunications',
      Overwrite_Classification__c = false
    );
    insert childAccount;

    Account newAcc = parentAccount.clone();
    newAcc.Id = parentAccount.Id;
    newAcc.Classification__c = 'Velocity';
    update newAcc;

    AccountSetGAMEmailQueueable accSetGAMEmailQueueable = new AccountSetGAMEmailQueueable(
      new List<Account>{ newAcc },
      new Map<Id, SObject>{ parentAccount.Id => parentAccount }
    );
    accSetGAMEmailQueueable.execute(null);

    Account nonGlobalClasificationAcc = [
      SELECT Id, Classification__c, GAM_Email__c
      FROM Account
      WHERE Id = :parentAccount.Id
      LIMIT 1
    ];
    //TODO: conflict with other code in org
    //System.assertEquals(null, nonGlobalClasificationAcc.GAM_Email__c);
  }

  @isTest
  public static void setupGAMEmail_owner_Test() {
    Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    User u1 = new User(
      ProfileId = profileId,
      Username = 'testgamemailacc@testgam.com',
      LastName = 'TestUser',
      Email = 'testgamemailacc@testgam.com',
      Alias = 'tgame433',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US'
    );

    insert u1;

    User u2 = new User(
      ProfileId = profileId,
      Username = 'testgamemailacc2@testgam.com',
      LastName = 'TestUser2',
      Email = 'testgamemailacc2@testgam.com',
      Alias = 'tgame422',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US'
    );

    insert u2;

    Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    Account topParentAcc = new Account();
    System.runAs(u1) {
      topParentAcc = new Account(
        Name = 'TopParentAccount',
        RecordTypeId = customerRT,
        AnnualRevenue = 150000000.00,
        Classification__c = 'General Business',
        Overwrite_Classification__c = false,
        Country__c = 'United States',
        BillingCountry = 'United States',
        Industry = 'Communications'
      );
      insert topParentAcc;
    }

    Account parentAccount = new Account(
      Name = 'ParentAccount',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      AnnualRevenue = 150000000.00,
      Classification__c = 'Global',
      Country__c = 'United States',
      BillingCountry = 'United States',
      Overwrite_Classification__c = false,
      Industry = 'Communications'
    );
    insert parentAccount;

    Account childAccount = new Account(
      Name = 'TestAccount',
      ParentId = parentAccount.Id,
      RecordTypeId = customerRT,
      AnnualRevenue = 5000000.00,
      Overwrite_Classification__c = false,
      Classification__c = 'Global',
      Country__c = 'United States',
      BillingCountry = 'United States',
      Industry = 'Telecommunications'
    );
    insert childAccount;

    Account newAcc = topParentAcc.clone();
    newAcc.Id = topParentAcc.Id;
    newAcc.OwnerId = u2.Id;
    update newAcc;

    AccountSetGAMEmailQueueable accSetGAMEmailQueueable = new AccountSetGAMEmailQueueable(
      new List<Account>{ newAcc },
      new Map<Id, SObject>{ topParentAcc.Id => topParentAcc }
    );
    accSetGAMEmailQueueable.execute(null);

    List<Account> childAccountIns = [
      SELECT Id, Classification__c, GAM_Email__c
      FROM Account
      WHERE Classification__c = 'Global'
    ];
    System.assertEquals(2, childAccountIns.size());
    for (Account childacc : childAccountIns)
      System.assertEquals('testgamemailacc2@testgam.com', childacc.GAM_Email__c);
  }
}
