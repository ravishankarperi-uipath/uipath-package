@IsTest
public class OrchestratorNotifierTest {
  //Connector template for tests
  public static final String TEST_TEMPLATE = 'TEST_ORCH_NOTIFY_TEMPLATE';

  @IsTest
  public static void callsNotifyOnNewAccount() {
    List<Account> accounts = new List<Account>{
      new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test1', BillingCountry = 'India'),
      new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test2', BillingCountry = 'Romania')
    };

    OrchestratorNotifierQueueable notifier = OrchestratorNotifierQueueable.beginSetup(accounts, TEST_TEMPLATE)
      .setSyncMode(true)
      .endSetup();

    notifier.publishNewRecords();

    //A log entry should exist if the connector framework tried to publish
    //We cannot test actual notification without a live orchestrator
    System.assertEquals(
      true,
      [SELECT Id, UiPath__Details__c FROM UiPath__UiPathLog__c LIMIT 1]
        .UiPath__Details__c.contains('TEST_ORCH_NOTIFY_TEMPLATE'),
      'There should be a failed attempt in the logs'
    );

    System.assertEquals(2, notifier.numberOfRecordsPublished, 'There should be 2 records published');
    System.assertEquals('add', notifier.getParams().get('action'), 'Should have set a add action');
  }

  @IsTest
  public static void callsNotifyOnlyOnFilteredAccounts() {
    List<Account> accounts = new List<Account>{
      new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test1', BillingCountry = 'India'),
      new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Test2', BillingCountry = 'Romania'),
      new Account(
        Id = fflib_IDGenerator.generate(Account.SObjectType),
        Name = 'Test2',
        BillingCountry = 'United Kingdom'
      )
    };

    OrchestratorNotifierQueueable notifier = OrchestratorNotifierQueueable.beginSetup(accounts, TEST_TEMPLATE)
      .setSyncMode(true)
      .withFilterConditions(Match.field(Account.BillingCountry).isIn(new Set<String>{ 'India', 'Romania' }))
      .endSetup();
    notifier.publishNewRecords();

    System.assertEquals(
      1,
      [SELECT COUNT() FROM UiPath__UiPathLog__c],
      'There should only be 1 record publishing attempt'
    );
    System.assertEquals(2, notifier.numberOfRecordsPublished, 'There should be 2 records published');

    System.assertEquals('add', notifier.getParams().get('action'), 'Should have set a add action');
  }

  @IsTest
  public static void callsNotifyOnUpdatedAccount() {
    Account oldAccount = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test1',
      BillingCountry = 'India'
    );

    List<Account> updatedAccounts = new List<Account>{
      new Account(Id = oldAccount.Id, Name = 'Test1', BillingCountry = 'Romania')
    };

    OrchestratorNotifierQueueable notifier = OrchestratorNotifierQueueable.beginSetup(updatedAccounts, TEST_TEMPLATE)
      .setSyncMode(true)
      .withFieldsToCheckForChange(new Set<SObjectField>{ Account.BillingCountry })
      .withOldRecords(new Map<Id, SObject>{ oldAccount.Id => oldAccount })
      .endSetup();

    notifier.publishUpdatedRecords();

    System.assertEquals(
      true,
      [SELECT Id, UiPath__Details__c FROM UiPath__UiPathLog__c LIMIT 1]
        .UiPath__Details__c.contains('TEST_ORCH_NOTIFY_TEMPLATE'),
      'There should be a failed attempt in the logs'
    );
    System.assertEquals(1, notifier.numberOfRecordsPublished, 'There should be 1 record published');

    System.assertEquals('update', notifier.getParams().get('action'), 'Should have set a update actiomn');
  }

  @IsTest
  public static void doesNotCallNotifyIfSpecifiedFieldsDontChange() {
    Account oldAccount = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test1',
      BillingCountry = 'India'
    );

    List<Account> updatedAccounts = new List<Account>{
      new Account(Id = oldAccount.Id, Name = 'Test1', BillingCountry = 'Romania')
    };

    OrchestratorNotifierQueueable notifier = OrchestratorNotifierQueueable.beginSetup(updatedAccounts, TEST_TEMPLATE)
      .setSyncMode(true)
      .withFieldsToCheckForChange(new Set<SObjectField>{ Account.Name })
      .withOldRecords(new Map<Id, SObject>{ oldAccount.Id => oldAccount })
      .endSetup();

    notifier.publishUpdatedRecords();

    //Note that in the data only Billing Country is actually updated but Name is specified as the field to check
    System.assertEquals(0, notifier.numberOfRecordsPublished, 'There should be no records published');
  }

  @IsTest
  public static void throwsWhenNoFieldsAreSpecifiedInUpdateMode() {
    Account oldAccount = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test1',
      BillingCountry = 'India'
    );

    List<Account> updatedAccounts = new List<Account>{
      new Account(Id = oldAccount.Id, Name = 'Test1', BillingCountry = 'Romania')
    };

    OrchestratorNotifierQueueable notifier = OrchestratorNotifierQueueable.beginSetup(updatedAccounts, TEST_TEMPLATE)
      .setSyncMode(true)
      .withOldRecords(new Map<Id, SObject>{ oldAccount.Id => oldAccount })
      .endSetup();

    IllegalStateException expectedEx;
    try {
      notifier.publishUpdatedRecords();
    } catch (IllegalStateException e) {
      expectedEx = e;
    }
    System.assert(
      expectedEx.getMessage().equals('At least one field must be provided in the fieldsToCheckForChange parameter')
    );
  }
}
