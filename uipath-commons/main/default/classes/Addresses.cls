/**
 * Responsibility: Account Domain Class
 * Mostly just delegates work to Mapped Functions or to Async Queueables
 */
public with sharing class Addresses extends fflib_SObjectDomain implements IAddresses {
  public static IAddresses newInstance(List<Account> recordList) {
    return (IAddresses) Application.Domain.newInstance(recordList);
  }

  public static IAddresses newInstance(Set<Id> recordIdSet) {
    return (IAddresses) Application.Domain.newInstance(recordIdSet);
  }

  public Addresses(List<Account> sObjectList) {
    super(sObjectList);
    this.Configuration.disableTriggerCRUDSecurity();
  }

  public override void onBeforeInsert() {
  }

  public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
  }

  public override void onAfterInsert() {
    AddressOrchestratorNotificationQueueable.publishNewAddressesToNetsuite(Records);
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    AddressOrchestratorNotificationQueueable.publishUpdatedAddressesToNetsuite(Records, existingRecords);
  }

  public override void onAfterDelete() {
  }

  /**
   * Validates Addresses inserted or Updated
   */
  public override void onValidate() {
  }

  /**
   * Validates Addresses that are updated
   * @param existingRecords updated Records
   */
  public override void onValidate(Map<Id, SObject> existingRecords) {
  }

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new Addresses(sObjectList);
    }
  }
}
