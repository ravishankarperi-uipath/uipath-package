@IsTest
public class AccountProactiveServiceQueueableTest {
  @TestSetup
  static void makeData() {
    Account account = new Account(Name = 'John');
    account.BillingStreet = 'Test Street';
    account.BillingCity = 'Test City';
    account.BillingPostalCode = 'SW1 3DWW';
    account.BillingCountry = 'United Kingdom';
    account.Phone = '1234567890';
    account.Industry = 'Others';
    insert account;

    Contact contact = new Contact();
    contact.LastName = 'Doe';
    contact.AccountId = account.Id;
    contact.Email = 'john.doe@uipathTest.com';
    insert contact;

    List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'UiPath Japan Partner Community'];
    if (profiles.isEmpty()) {
      return;
    }

    User communityUser = new User();
    communityUser.ProfileId = profiles.get(0).Id;
    communityUser.FirstName = 'John';
    communityUser.LastName = 'Doe';
    communityUser.Alias = 'Doe';
    communityUser.Email = 'john.doe@uipathTest.com';
    communityUser.Username = 'john.doe@uipathTest.com';
    communityUser.TimeZoneSidKey = 'America/Los_Angeles';
    communityUser.EmailEncodingKey = 'UTF-8';
    communityUser.LanguageLocaleKey = 'en_US';
    communityUser.LocaleSidKey = 'en_US';
    communityUser.ContactId = contact.Id;
    insert communityUser;
  }

  static testMethod void validateAndUpdateCounter_newProactiveCaseIsCreated() {
    List<User> communityUsers = [SELECT Id FROM User WHERE Username = 'john.doe@uipathTest.com'];
    if (communityUsers.isEmpty()) {
      return;
    }
    System.runAs(communityUsers.get(0)) {
      Case proactiveCareCase = new Case();
      proactiveCareCase.RecordTypeId = CaseMetadata.ProactiveCareRecordType;
      proactiveCareCase.Subject = 'Proactive Case';
      proactiveCareCase.Status = 'New';
      proactiveCareCase.Start_Date__c = System.today().addDays(15);
      Test.startTest();
      new AccountProactiveServiceQueueable(new List<Case>{ proactiveCareCase }).execute(null);
      Test.stopTest();
    }

    Account account = [
      SELECT Id, of_Proactive_services__c, Max_of_Services_Quarter__c, requests_this_quarter__c
      FROM Account
      LIMIT 1
    ];
    System.assertEquals(5, account.of_Proactive_services__c, 'Proactive Services count');
    System.assertEquals(6, account.Max_of_Services_Quarter__c, 'Maximum Services allowed this quarter.');
    System.assertEquals(1, account.requests_this_quarter__c, 'Requests this Quarter.');
  }
}
