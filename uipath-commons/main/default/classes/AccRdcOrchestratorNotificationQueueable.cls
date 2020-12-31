/**
 * Created by roxana.anghel on 12/3/2020.
 * Publishes events to the Uipath Connector framework - which then sends the account details for verification in RDC
 */

public with sharing class AccRdcOrchestratorNotificationQueueable {
  /**
   * Sends new Accounts to Orchestrator for RDC Verification
   * @param records inserted items
   */

  public static void publishInsertsToRDC(List<SObject> records) {
    OrchestratorNotifierQueueable.beginSetup(records, CommonsConstants.ACC_RDC_UIPATH_SF_CONNECTOR_TEMPLATE)
      .withFilterConditions(
        Match.field(Account.RecordTypeId)
          .isIn(
            new Set<String>{
              AccountMetadata.partnerProspectRecordType,
              AccountMetadata.partnerRecordType,
              AccountMetadata.technologyAllianceRecordType
            }
          )
      )
      .endSetup()
      .publishNewRecords();
  }
}
