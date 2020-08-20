@isTest
private class AccountSharingLeadOwnerQueueableTest {
  @TestSetup
  private static void makeData() {
    List<Profile> p = [SELECT Id FROM Profile WHERE Name = 'UiPath Japan Partner Community' LIMIT 1];
    if (p.isEmpty()) {
      p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

      User u1 = new User(
        LastName = 'TestCommunityUser1',
        Alias = 'user1',
        Email = 'user1' + Date.today().format() + '@uipath.com.community.testuser',
        UserName = 'user1' + Date.today().format() + '@uipath.com.community.testuser',
        EmailEncodingKey = 'ISO-2022-JP',
        TimeZoneSidKey = 'Asia/Tokyo',
        LocaleSidKey = 'ja_JP',
        LanguageLocaleKey = 'ja',
        ProfileId = p[0].Id
      );
      insert u1;
    } else {
      Account a1 = new Account(
        Name = 'NewAccountABC',
        BillingCountry = 'United Kingdom',
        Industry = 'Others',
        LD_USE_DnB_Optimize__c = false
      );
      insert a1;
      Contact con = new Contact(
        FirstName = 'Testadasda',
        LastName = 'Test',
        Email = 'asdasdad.test@test.com',
        AccountId = a1.Id,
        MailingCountry = 'Australia',
        MailingState = '',
        Title = 'Test',
        LeadSource = 'Webinar'
      );
      insert con;

      System.runAs(new User(Id = UserInfo.getUserId())) {
        User u1 = new User(
          LastName = 'TestCommunityUser1',
          Alias = 'user1',
          Email = 'user1' + Date.today().format() + '@uipath.com.community.testuser',
          UserName = 'user1' + Date.today().format() + '@uipath.com.community.testuser',
          EmailEncodingKey = 'ISO-2022-JP',
          TimeZoneSidKey = 'Asia/Tokyo',
          LocaleSidKey = 'ja_JP',
          LanguageLocaleKey = 'ja',
          ProfileId = p[0].Id,
          ContactId = con.Id
        );
        insert u1;
      }
    }
  }

  @isTest
  private static void shareAccountWithLeadOwnerTest() {
    User u1 = [SELECT Id FROM User WHERE LastName = 'TestCommunityUser1' LIMIT 1];
    Account acc = new Account(
      Name = 'Test Acc',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      LD_USE_DnB_Optimize__c = false
    );
    insert acc;

    acc.OwnerFromLead__c = u1.Id;
    update acc;

    AccountSharingLeadOwnerQueueable accountSharingLeadOwnerQueueable = new AccountSharingLeadOwnerQueueable(
      new List<Account>{ acc }
    );
    accountSharingLeadOwnerQueueable.execute(null);

    system.assertEquals(
      true,
      [SELECT Id, OwnerFromLead__c FROM Account WHERE Id = :acc.Id].OwnerFromLead__c == null,
      'OwnerFromLead__c is not cleared'
    );
  }
}
