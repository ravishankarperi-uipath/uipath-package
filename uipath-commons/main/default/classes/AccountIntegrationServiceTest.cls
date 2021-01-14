@IsTest
public with sharing class AccountIntegrationServiceTest {
  public static final String CONFIRMATION_MESSAGE = 'There should be a publish attempt in the logs';

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
      CONFIRMATION_MESSAGE
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
      CONFIRMATION_MESSAGE
    );
  }

  @IsTest
  public static void publishesInsertsToRDC() {
    Account acc = new Account(
      Name = 'Test Partner Prospect',
      BillingCountry = 'Austria',
      BillingCountryCode = 'AT',
      Country__c = 'Austria',
      Industry = 'Apparel',
      RecordTypeId = AccountMetadata.partnerProspectRecordType
    );

    //Set to force a sync publish - which normally happens via a queueable
    OrchestratorNotifierQueueable.forceSyncMode = true;
    insert acc;

    List<UiPath__UiPathLog__c> logList = new List<UiPath__UiPathLog__c>();

    for (UiPath__UiPathLog__c log : [
      SELECT Id, UiPath__Details__c
      FROM UiPath__UiPathLog__c
      WHERE CreatedDate = TODAY
    ]) {
      if (log.Uipath__Details__c.contains(CommonsConstants.ACC_RDC_UIPATH_SF_CONNECTOR_TEMPLATE)) {
        logList.add(log);
      }
    }

    System.assertEquals(true, !logList.isEmpty(), CONFIRMATION_MESSAGE);
  }
}
