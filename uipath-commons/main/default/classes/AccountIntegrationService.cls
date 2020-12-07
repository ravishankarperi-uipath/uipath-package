/**
 * Just a bunch of Static Utility methods - each publishing Accounts to the UiPath Orchestrator in specific circumstances
 * These methods have been separated into this class to keep the domains small and readable
 */
public with sharing class AccountIntegrationService {
  /**
   * Sends new Accounts to Netsuite
   * @param records inserted items
   */
  public static void publishInsertsToNetsuite(List<SObject> records) {
    OrchestratorNotifierQueueable.beginSetup(Records, CommonsConstants.ACC_UIPATH_SF_CONNECTOR_TEMPLATE)
      .withFilterConditions(
        Match.field(Account.Sync_Status__c)
          .isIn(new Set<String>{ CommonsConstants.ACC_SYNC_STATUS_VALID, CommonsConstants.ACC_SYNC_STATUS_PENDING })
      )
      .endSetup()
      .publishNewRecords();
  }

  /**
   * Sends updated Accounts to Netsuite
   * @param records updated objects
   * @param oldRecords objects as previously saved in DB
   */
  public static void publishUpdatesToNetsuite(List<SObject> records, Map<Id, SObject> oldRecords) {
    OrchestratorNotifierQueueable.beginSetup(records, CommonsConstants.ACC_UIPATH_SF_CONNECTOR_TEMPLATE)
      .withFilterConditions(
        Match.field(Account.Sync_Status__c)
          .isIn(new Set<String>{ CommonsConstants.ACC_SYNC_STATUS_VALID, CommonsConstants.ACC_SYNC_STATUS_PENDING })
      )
      .withFieldsToCheckForChange(new Set<SObjectField>{ Account.Sync_Status__c })
      .withOldRecords(oldRecords)
      .endSetup()
      .publishUpdatedRecords();
  }
}
