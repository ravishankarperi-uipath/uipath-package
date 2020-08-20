@isTest
private class AccountSetClassificationFunctionTest {
  @isTest
  private static void setClassificationFieldTest() {
    Id prospectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();

    Account account1 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test1',
      Geo__c = 'APAC',
      RecordTypeId = prospectRT,
      AnnualRevenue = 150000000.00,
      Overwrite_Classification__c = false
    );
    Account oldAccount1 = new Account(Id = account1.Id, Name = 'Test1');

    Account account2 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test2',
      Geo__c = 'AMER',
      Region__c = 'LATAM',
      RecordTypeId = prospectRT,
      AnnualRevenue = 150000000.00,
      Overwrite_Classification__c = false
    );
    Account oldAccount2 = new Account(Id = account2.Id, Name = 'Test2');

    Account account3 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test3',
      Geo__c = 'EMEA',
      RecordTypeId = prospectRT,
      AnnualRevenue = 250000000.00,
      Overwrite_Classification__c = false
    );
    Account oldAccount3 = new Account(Id = account3.Id, Name = 'Test3');

    Account account4 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test4',
      Geo__c = 'AMER',
      Region__c = 'LATAM',
      RecordTypeId = prospectRT,
      AnnualRevenue = 140000000.00,
      Overwrite_Classification__c = false
    );
    Account oldAccount4 = new Account(Id = account4.Id, Name = 'Test4');

    Account account5 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test5',
      Geo__c = 'India',
      RecordTypeId = prospectRT,
      AnnualRevenue = 10.00,
      Overwrite_Classification__c = false
    );
    Account oldAccount5 = new Account(Id = account5.Id, Name = 'Test5');

    Account account6 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test6',
      Geo__c = 'APAC',
      RecordTypeId = prospectRT,
      AnnualRevenue = 250000000.00,
      Overwrite_Classification__c = false
    );
    Account oldAccount6 = new Account(Id = account6.Id, Name = 'Test6');

    Account account7 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test7',
      Geo__c = 'EMEA',
      RecordTypeId = prospectRT,
      AnnualRevenue = 240000000.00,
      Overwrite_Classification__c = false
    );
    Account oldAccount7 = new Account(Id = account7.Id, Name = 'Test7');

    Account account8 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test8',
      Geo__c = 'AMER',
      Region__c = 'Canada',
      RecordTypeId = prospectRT,
      AnnualRevenue = 200000000.00,
      Overwrite_Classification__c = false
    );
    Account oldAccount8 = new Account(Id = account8.Id, Name = 'Test8');

    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Account>{ account1, account2, account3, account4, account5, account6, account7, account8 },
      new Map<Id, SObject>{
        oldAccount1.Id => oldAccount1,
        oldAccount2.Id => oldAccount2,
        oldAccount3.Id => oldAccount3,
        oldAccount4.Id => oldAccount4,
        oldAccount5.Id => oldAccount5,
        oldAccount6.Id => oldAccount6,
        oldAccount7.Id => oldAccount7,
        oldAccount8.Id => oldAccount8
      }
    );
    fflib_SObjectDomain.triggerHandler(Accounts.class);

    System.assertEquals(account1.Classification__c, 'SMB');
    System.assertEquals(account2.Classification__c, 'Enterprise');
    System.assertEquals(account3.Classification__c, 'Commercial');
    System.assertEquals(account4.Classification__c, 'Velocity');
    System.assertEquals(account5.Classification__c, 'Commercial');
    System.assertEquals(account6.Classification__c, 'Commercial');
    System.assertEquals(account7.Classification__c, 'SMB');
    System.assertEquals(account8.Classification__c, 'Enterprise');
  }
}
