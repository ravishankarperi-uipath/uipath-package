/**
 * TODO REWRITE with fflib Mocking
 */
@isTest
private class AccountDNBCompanyQueueableTest {
  @isTest
  private static void processDNBCompanyTest() {
    Account acc = new Account(
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      Industry = 'Others'
    );
    insert acc;

    Account newAcc = acc.clone();
    newAcc.Id = acc.Id;
    newAcc.DnB_Country__c = 'United Kingdom';
    update newAcc;

    AccountDNBCompanyQueueable accountDNBCompanyQueueable = new AccountDNBCompanyQueueable(
      new List<Account>{ newAcc },
      new Map<Id, SObject>{ acc.Id => acc }
    );
    accountDNBCompanyQueueable.execute(null);

    List<Address__c> addList = [
      SELECT Id
      FROM Address__c
      WHERE Account__c = :acc.Id
    ];
    System.assertEquals(1, addList.size(), 'Address not created properly');
  }
}
