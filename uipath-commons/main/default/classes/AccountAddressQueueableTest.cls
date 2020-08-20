/**
 * TODO REWRITE with fflib Mocking
 */
@isTest
private class AccountAddressQueueableTest {
  @isTest
  private static void createAddressTest() {
    Account acc = new Account(
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      DnB_Country__c = 'United Kingdom',
      DnB_Street__c = 'Test DnB Country Street1. Needs to be more than 150 character in size to test apex code.' +
        'Test  DnB Country Street2. Needs to be more than 150 character in size to test apex code.'
    );

    insert acc;

    AccountAddressQueueable accountAddressQueueable = new AccountAddressQueueable(new List<Account>{ acc }, null);
    accountAddressQueueable.execute(null);

    List<Address__c> addList = [SELECT Id FROM Address__c WHERE Account__c = :acc.Id];
    System.assertEquals(true, addList.size() > 0, 'Address not created properly');
  }
}
