/**
 * TODO REWRITE with Mocking as too much DML involved
 */
@isTest
public class AccountSharingRollupQueueableTest {
  @isTest
  public static void canRunAccountSharingJobOnInsert() {
    User u1 = new User();
    u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
    .Id;
    u1.Username = 'canRunAccountSharingJob@uipath.com';
    u1.LastName = 'Test';
    u1.Email = 'canRunAccountSharingJob@uipath.com';
    u1.Alias = 't839734';
    u1.TimeZoneSidKey = 'America/Los_Angeles';
    u1.LocaleSidKey = 'en_US';
    u1.EmailEncodingKey = 'UTF-8';
    u1.LanguageLocaleKey = 'en_US';

    insert u1;

    Account ukAccountParent = new Account(
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      OwnerId = u1.Id,
      Industry = 'Others'
    );

    insert ukAccountParent;

    Account ukAccountChild = ukAccountParent.clone();
    ukAccountChild.Name = 'ChildTestAccountUK';
    ukAccountChild.ParentId = ukAccountParent.Id;
    ukAccountChild.Classification__c = 'Global';
    ukAccountChild.OwnerId = UserInfo.getUserId();

    insert ukAccountChild;

    AccountSharingRollupQueueable accountSharingRollupQueueable = new AccountSharingRollupQueueable(
      new List<Account>{ ukAccountChild },
      null
    );
    accountSharingRollupQueueable.execute(null);

    List<AccountShare> accountShares = [
      SELECT Id
      FROM AccountShare
      WHERE
        AccountId = :ukAccountChild.Id
        AND AccountAccessLevel = 'Edit'
        AND OpportunityAccessLevel = 'Edit'
        AND UserOrGroupId = :u1.Id
    ];
    System.assertEquals(
      1,
      accountShares.size(),
      'Parent Account owner should have edit access to Account and Opty'
    );
  }

  @isTest
  public static void canRunAccountSharingJobOnUpdateOfParentOwner() {
    User u1 = new User();
    u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
    .Id;
    u1.Username = 'canRunAccountSharingJob@uipath.com';
    u1.LastName = 'Test';
    u1.Email = 'canRunAccountSharingJob@uipath.com';
    u1.Alias = 't839734';
    u1.TimeZoneSidKey = 'America/Los_Angeles';
    u1.LocaleSidKey = 'en_US';
    u1.EmailEncodingKey = 'UTF-8';
    u1.LanguageLocaleKey = 'en_US';

    User u2 = new User();
    u2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
    .Id;
    u2.Username = '2canRunAccountSharingJob@uipath.com';
    u2.LastName = '2Test';
    u2.Email = '2canRunAccountSharingJob@uipath.com';
    u2.Alias = '2t839734';
    u2.TimeZoneSidKey = 'America/Los_Angeles';
    u2.LocaleSidKey = 'en_US';
    u2.EmailEncodingKey = 'UTF-8';
    u2.LanguageLocaleKey = 'en_US';

    insert new List<User>{ u1, u2 };

    Account ukAccountParent = new Account(
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      OwnerId = u1.Id,
      Industry = 'Others'
    );

    insert ukAccountParent;

    Account ukAccountChild = ukAccountParent.clone();
    ukAccountChild.Name = 'ChildTestAccountUK';
    ukAccountChild.ParentId = ukAccountParent.Id;
    ukAccountChild.Classification__c = 'Global';
    ukAccountChild.OwnerId = UserInfo.getUserId();

    insert ukAccountChild;

    AccountSharingRollupQueueable accountSharingRollupQueueable = new AccountSharingRollupQueueable(
      new List<Account>{ ukAccountChild },
      null
    );
    accountSharingRollupQueueable.execute(null);

    ukAccountParent.OwnerId = u2.Id;
    update ukAccountParent;

    AccountSharingRollupQueueable accountSharingRollupQueueable2 = new AccountSharingRollupQueueable(
      new List<Account>{ ukAccountChild },
      null
    );
    accountSharingRollupQueueable2.execute(null);

    List<AccountShare> accountShares = [
      SELECT Id
      FROM AccountShare
      WHERE
        AccountId = :ukAccountChild.Id
        AND AccountAccessLevel = 'Edit'
        AND OpportunityAccessLevel = 'Edit'
        AND UserOrGroupId = :u2.Id
    ];
    System.assertEquals(
      1,
      accountShares.size(),
      'Parent Account owner should have edit access to Account and Opty'
    );
  }
}
