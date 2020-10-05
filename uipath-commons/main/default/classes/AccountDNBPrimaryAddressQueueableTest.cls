@isTest
private class AccountDNBPrimaryAddressQueueableTest {
  private static final string USA = 'United States';
  private static final string State_CA = 'California';
  private static final string State_NY = 'New York';

  @isTest
  private static void updatePrimaryDNBTest() {
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
    newAcc.DnB_State_Province__c = State_NY;
    update newAcc;

    AccountDNBCompanyQueueable accountDNBCompanyQueueable = new AccountDNBCompanyQueueable(
      new List<Account>{ newAcc },
      new Map<Id, SObject>{ acc.Id => acc }
    );
    accountDNBCompanyQueueable.execute(null);

    Account newAcc1 = acc.clone();
    newAcc1.Id = acc.Id;
    newAcc1.DnB_City__c = State_NY;
    newAcc1.DnB_Street__c = '432 Ave';
    newAcc1.DnB_Zip_Postal_Code__c = '90210';
    update newAcc1;

    AccountDNBPrimaryAddressQueueable accountDNBPrimaryAddressQueueable = new AccountDNBPrimaryAddressQueueable(
      new List<Account>{ newAcc1 },
      new Map<Id, SObject>{ acc.Id => acc }
    );
    accountDNBPrimaryAddressQueueable.execute(null);

    List<Address__c> addList = [
      SELECT Id, Country__c, State__c, City__c, Street_Line_1__c, Zip_Postal_Code__c
      FROM Address__c
      WHERE Account__c = :acc.Id AND Primary_Billing__c = true
      LIMIT 1
    ];
    System.assertEquals(USA, addList[0].Country__c);
    System.assertEquals(State_NY, addList[0].State__c);
    System.assertEquals(State_NY, addList[0].City__c);
    System.assertEquals('432 Ave', addList[0].Street_Line_1__c);
    System.assertEquals('90210', addList[0].Zip_Postal_Code__c);
  }
}
