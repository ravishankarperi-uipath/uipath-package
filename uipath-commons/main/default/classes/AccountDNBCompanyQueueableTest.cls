/**
 * TODO REWRITE with fflib Mocking
 */
@isTest
private class AccountDNBCompanyQueueableTest {
  private static final string USA = 'United States';
  private static final string State_CA = 'California';

  @isTest
  private static void processDNBCompanyTest() {
    Account acc = new Account(
      Name = 'TestAccountUK',
      Country__c = USA,
      State__c = State_CA,
      BillingCountryCode = 'US',
      BillingCountry = USA,
      BillingStateCode = 'CA',
      BillingState = State_CA,
      DnB_State_Province__c = State_CA,
      Industry = 'Others'
    );
    insert acc;

    Account newAcc = acc.clone();
    newAcc.Id = acc.Id;
    newAcc.DnB_Country__c = USA;
    newAcc.DnB_State_Province__c = 'New York';
    update newAcc;

    AccountDNBCompanyQueueable accountDNBCompanyQueueable = new AccountDNBCompanyQueueable(
      new List<Account>{ newAcc },
      new Map<Id, SObject>{ acc.Id => acc }
    );
    accountDNBCompanyQueueable.execute(null);

    List<Address__c> addList = [SELECT Id FROM Address__c WHERE Account__c = :acc.Id];
    System.assertEquals(true, addList.size() > 0, 'Address not created properly');
  }
}
