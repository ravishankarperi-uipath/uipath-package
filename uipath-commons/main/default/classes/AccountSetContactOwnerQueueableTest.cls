/**
 * TODO REWRITE with fflib Mocking
 */
@isTest
private class AccountSetContactOwnerQueueableTest {
  @isTest
  private static void setUpContactOwnerTest() {
    User u1 = new User();
    u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    u1.Username = 'testtsettest1@uipath.com';
    u1.LastName = 'Test1';
    u1.Email = 'testtsettest1@uipath.com';
    u1.Alias = 't839734';
    u1.TimeZoneSidKey = 'America/Los_Angeles';
    u1.LocaleSidKey = 'en_US';
    u1.EmailEncodingKey = 'UTF-8';
    u1.LanguageLocaleKey = 'en_US';
    insert u1;

    User u2 = new User();
    u2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    u2.Username = 'testtsettest2@uipath.com';
    u2.LastName = 'Test2';
    u2.Email = 'testtsettest2@uipath.com';
    u2.Alias = 't8397342';
    u2.TimeZoneSidKey = 'America/Los_Angeles';
    u2.LocaleSidKey = 'en_US';
    u2.EmailEncodingKey = 'UTF-8';
    u2.LanguageLocaleKey = 'en_US';
    insert u2;

    Account acc = new Account(
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      OwnerId = u1.Id
    );
    insert acc;

    Account newAcc = acc.clone();
    newAcc.Id = acc.Id;
    newAcc.OwnerId = u2.Id;
    update newAcc;

    AccountSetContactOwnerQueueable accountSetContactOwnerQueueable = new AccountSetContactOwnerQueueable(
      new List<Account>{ newAcc },
      new Map<Id, SObject>{ acc.Id => acc }
    );
    accountSetContactOwnerQueueable.execute(null);

    //TODO: Contact test data and assert
    System.assertEquals(true, acc.OwnerId != newAcc.OwnerId);
  }
}
