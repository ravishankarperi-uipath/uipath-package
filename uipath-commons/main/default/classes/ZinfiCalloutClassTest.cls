/**
 * TODO refactor code in next iteration
 */
@SuppressWarnings('PMD')
@isTest
private class ZinfiCalloutClassTest {
  @TestSetup
  static void makeData() {
    ZinfiConfiguration__c zinfiSetting = new ZinfiConfiguration__c();
    zinfiSetting.IsSyncAccount__c = true;
    zinfiSetting.WebHook__c = 'WebHook';
    zinfiSetting.WebHookContact__c = 'WebHookContact';
    zinfiSetting.WebhookEndPoint__c = 'WebhookEndPoint';
    zinfiSetting.WebToken__c = 'WebToken';
    insert zinfiSetting;
  }

  @isTest
  static void testZinfiDeleteCallout() {
    Test.startTest();
    //Test.setMock(HttpCalloutMock.class, new ZinfiMockHttp());

    Account acc2 = new Account();
    acc2.Name = 'Zinfi Test Account';
    acc2.Partner_Portal_Contact_Sync__c = true;
    acc2.Business_Partner_Status__c = 'Good Standing';
    acc2.Country__c = 'Australia';
    acc2.State__c = 'Victoria';
    acc2.Classification__c = 'Commercial';
    acc2.Industry = 'Banking and Financial Services';
    insert acc2;

    Contact contact2 = new Contact();
    contact2.FirstName = 'Zinfi';
    contact2.LastName = 'Test';
    contact2.Email = 'zinfi.test@test.com';
    contact2.AccountId = acc2.Id;
    contact2.MailingCountry = 'Australia';
    contact2.MailingState = '';
    contact2.Title = 'Test';
    contact2.LeadSource = 'Webinar';
    insert contact2;
    delete contact2;
    delete acc2;

    Test.stopTest();
  }

  @isTest
  static void testZinfiUpdateCallout() {
    Test.startTest();
    //Test.setMock(HttpCalloutMock.class, new ZinfiMockHttp());

    Account acc = new Account();
    acc.Name = 'Zinfi Test Account';
    acc.Partner_Portal_Contact_Sync__c = true;
    acc.Business_Partner_Status__c = 'Good Standing';
    acc.Country__c = 'United States';
    acc.Classification__c = 'Commercial';
    acc.Industry = 'Banking and Financial Services';
    insert acc;

    Contact contact = new Contact();
    contact.FirstName = 'Zinfi';
    contact.LastName = 'Test';
    contact.Email = 'zinfi.test@test.com';
    contact.AccountId = acc.Id;
    contact.MailingCountry = 'United States';
    contact.MailingState = '';
    contact.Title = 'Test';
    contact.LeadSource = 'Webinar';
    insert contact;

    acc.Name = 'Zinfi 1';
    update acc;

    Test.stopTest();
  }
}
