@IsTest
public with sharing class AccountIntegrationServiceTest {
  @IsTest
  public static void publishesInsertsToNetsuite() {
    Account acc = new Account(
      Name = 'Test 1',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      LD_USE_DnB_Optimize__c = false,
      Sync_Status__c = CommonsConstants.ACC_SYNC_STATUS_VALID
    );

    //Set to force a sync publish - which normally happens via a queueable
    OrchestratorNotifierQueueable.forceSyncMode = true;
    insert acc;

    System.assertEquals(
      true,
      [SELECT Id, UiPath__Details__c FROM UiPath__UiPathLog__c LIMIT 1]
        .UiPath__Details__c.contains(CommonsConstants.ACC_UIPATH_SF_CONNECTOR_TEMPLATE),
      'There should be a publish attempt in the logs'
    );
  }

  @IsTest
  public static void publishesUpdatesToNetsuite() {
    Account acc = new Account(
      Name = 'Test 1',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      LD_USE_DnB_Optimize__c = false,
      Validation_Status__c = CommonsConstants.ACC_VALIDATION_STATUS_VALIDATED
    );

    //Set to force a sync publish - which normally happens via a queueable
    insert acc;

    acc.BillingCountry = 'India';
    acc.Sync_Status__c = CommonsConstants.ACC_SYNC_STATUS_VALID;

    OrchestratorNotifierQueueable.forceSyncMode = true;
    update acc;

    System.assertEquals(
      true,
      [SELECT Id, UiPath__Details__c FROM UiPath__UiPathLog__c LIMIT 1]
        .UiPath__Details__c.contains(CommonsConstants.ACC_UIPATH_SF_CONNECTOR_TEMPLATE),
      'There should be a publish attempt in the logs'
    );
  }
}
