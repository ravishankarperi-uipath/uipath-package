/**
 * Publishes events to the Uipath Connector framework - which then sends the address to Netsuite
 */
public with sharing class AddressOrchestratorNotificationQueueable extends AbstractQueueable {
  private final List<SObject> addressList;
  public static Integer numEvents = 0;
  public AddressOrchestratorNotificationQueueable(List<SObject> addressList) {
    super('AddressOrchestratorNotificationQueueable');
    this.addressList = addressList;
  }

  public override void work() {
    this.publishOrchestratorNotification(this.addressList);
  }

  private void publishOrchestratorNotification(List<Address__c> addressList) {
    Set<Id> addIds = new Set<Id>();

    for (Address__c add : addressList) {
      if (
        add.Sync_Status__c == CommonsConstants.ADD_SYNC_STATUS_VALID ||
        add.Sync_Status__c == CommonsConstants.ADD_SYNC_STATUS_PENDING
      ) {
        addIds.add(add.Id);
      }
    }
    if (!addIds.isEmpty()) {
      numEvents = numEvents + addIds.size();
      IntegrationHandler.callUipathSFConnectorTemplate(addIds, CommonsConstants.ADD_UIPATH_SF_CONNECTOR_TEMPLATE);
    }
  }

  public static void publishNewAddressesToNetsuite(List<Address__c> adds) {
    List<Address__c> eligibleAccounts = (List<Address__c>) Collection.of(adds)
      .filter(Match.field(Address__c.Sync_Status__c).hasValue())
      .filter(
        Match.field(Address__c.Sync_Status__c)
          .isIn(new Set<String>{ CommonsConstants.ACC_SYNC_STATUS_VALID, CommonsConstants.ACC_SYNC_STATUS_PENDING })
      )
      .asList();

    if (!eligibleAccounts.isEmpty()) {
      AbstractQueueable.enqueue(new AddressOrchestratorNotificationQueueable(eligibleAccounts));
    }
  }

  public static void publishUpdatedAddressesToNetsuite(List<Address__c> adds, Map<Id, SObject> existingAdds) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Address__c.Sync_Status__c },
      adds,
      existingAdds
    );
    List<Address__c> eligibleAddresses = (List<Address__c>) Collection.of(adds)
      .filter(Match.field(Address__c.Sync_Status__c).hasValue())
      .filter(
        Match.field(Address__c.Sync_Status__c)
          .isIn(new Set<String>{ CommonsConstants.ACC_SYNC_STATUS_VALID, CommonsConstants.ACC_SYNC_STATUS_PENDING })
      )
      .filter(hasChanged)
      .asList();

    if (!eligibleAddresses.isEmpty()) {
      AbstractQueueable.enqueue(new AddressOrchestratorNotificationQueueable(eligibleAddresses));
    }
  }
}
