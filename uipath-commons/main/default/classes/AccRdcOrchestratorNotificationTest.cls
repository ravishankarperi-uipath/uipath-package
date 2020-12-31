/**
 * Created by roxana.anghel on 12/3/2020.
 */
@IsTest
private class AccRdcOrchestratorNotificationTest {
  public static final String CONFIRMATION_MESSAGE = 'There should be a publish attempt in the logs';
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

    System.assertEquals(
      true,
      [SELECT Id, UiPath__Details__c FROM UiPath__UiPathLog__c LIMIT 1]
        .UiPath__Details__c.contains(CommonsConstants.ACC_RDC_UIPATH_SF_CONNECTOR_TEMPLATE),
      CONFIRMATION_MESSAGE
    );
  }
}
