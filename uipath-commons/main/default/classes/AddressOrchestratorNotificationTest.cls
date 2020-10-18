/**
 * TODO REWRITE with fflib Mocking
 */
@isTest
private class AddressOrchestratorNotificationTest {
  @isTest
  private static void canPublishEventToQueue() {
    Account account1 = new Account(
      Name = 'Test1',
      BillingCountry = 'India',
      BillingCountryCode = 'IN',
      BillingStateCode = 'KA',
      Country__c = 'India',
      State__c = 'Karnataka',
      Industry = 'Apparel',
      Sync_Status__c = CommonsConstants.ACC_SYNC_STATUS_VALID
    );
    insert account1;

    Address__c add = new Address__c(
      Street_Line_1__c = 'Test Street Line 1',
      Street_Line_2__c = 'Test Street Line 2',
      City__c = 'Bangalore',
      State__c = 'Karnataka',
      Country__c = 'India',
      Zip_Postal_Code__c = '41677',
      GSTIN_India_only__c = '29AAACC1206C2ZB',
      Sync_Status__c = CommonsConstants.ADD_SYNC_STATUS_VALID,
      Account__c = account1.Id
    );

    insert add;
    AddressOrchestratorNotificationQueueable q1 = new AddressOrchestratorNotificationQueueable(
      new List<SObject>{ add }
    );
    q1.execute(null);

    System.assert(AddressOrchestratorNotificationQueueable.numEvents >= 1, 'At least 1 Account Event was published');

    // TODO figure out a way to assert a created event.
    // This doesn't work because the connector doesn't allow Template creation without a connection to a live Orchestrator
    //System.assertEquals(account1.Id, [SELECT Id,UiPath__RecordId__c FROM UiPath__OrchestratorNotification__c WHERE UiPath__RecordId__c = :account1.Id].UiPath__RecordId__c);
  }
}
