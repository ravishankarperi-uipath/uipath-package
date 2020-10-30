/**
 * Responsibility: Case Domain Class
 * Mostly just delegates work to Mapped Functions or to Async Queueables
 */
public with sharing class SalesCases extends fflib_SObjectDomain implements ICases {
  public static ICases newInstance(List<Case> recordList) {
    return (ICases) Application.Domain.newInstance(recordList);
  }

  public static ICases newInstance(Set<Id> recordIdSet) {
    return (ICases) Application.Domain.newInstance(recordIdSet);
  }

  public SalesCases(List<Case> sObjectList) {
    super(sObjectList);
    this.Configuration.disableTriggerCRUDSecurity();
  }

  public override void onBeforeInsert() {
    SalesCaseBillToWOOppFunction.updateBillToOnInsert(Records);
    SalesCaseBillToWOppQueueable.updateBillToOnInsert(Records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    SalesCaseOwnerAssignmentFunction.deriveOwnerOnUpdate(Records, existingRecords);
    SalesCaseBillToWOOppFunction.updateBillToOnUpdate(Records, existingRecords);
    SalesCaseBillToWOppQueueable.updateBillToOnUpdate(Records, existingRecords);
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    SalesCaseTechPartnerAgreementQueueable.deriveTechPartnershipDateOnAccount(Records, existingRecords);
  }

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new SalesCases(sObjectList);
    }
  }
}
