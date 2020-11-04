/**
 * Responsibility: Case Domain Class
 * Mostly just delegates work to Mapped Functions or to Async Queueables
 */
public with sharing class SalesCases extends fflib_SObjectDomain implements ISalesCases {
  public static ISalesCases newInstance(List<Case> recordList) {
    return (ISalesCases) Application.Domain.newInstance(recordList);
  }

  public static ISalesCases newInstance(Set<Id> recordIdSet) {
    return (ISalesCases) Application.Domain.newInstance(recordIdSet);
  }

  public SalesCases(List<Case> sObjectList) {
    super(sObjectList);
    this.Configuration.disableTriggerCRUDSecurity();
  }

  public override void onBeforeInsert() {
    SalesCaseBillToWOOppFunction.updateBillToOnInsert(Records);
    SalesCaseBillToWOppQueueable.updateBillToOnInsert(Records);
    SalesCaseStandardTemplateStampFunction.setStandardTemplateStampOnInsert(Records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    SalesCaseOwnerAssignmentFunction.deriveOwnerOnUpdate(Records, existingRecords);
    SalesCaseBillToWOOppFunction.updateBillToOnUpdate(Records, existingRecords);
    SalesCaseBillToWOppQueueable.updateBillToOnUpdate(Records, existingRecords);
    SalesCaseStandardTemplateStampFunction.setStandardTemplateStampOnUpdate(Records, existingRecords);
  }

  public override void onAfterInsert() {
    SalesCaseLegalOpportunityQueueable.deriveCaseCount(Records);
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    SalesCaseTechPartnerAgreementQueueable.deriveTechPartnershipDateOnAccount(Records, existingRecords);
  }

  public override void onAfterDelete() {
    SalesCaseLegalOpportunityQueueable.deriveCaseCount(Records);
  }

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new SalesCases(sObjectList);
    }
  }
}
