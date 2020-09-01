/**
 * Responsibility: Case Domain Class
 * Mostly just delegates work to Mapped Functions or to Async Queueables
 */
public with sharing class Cases extends fflib_SObjectDomain implements ICases {
  public static ICases newInstance(List<Case> recordList) {
    return (ICases) Application.Domain.newInstance(recordList);
  }

  public static ICases newInstance(Set<Id> recordIdSet) {
    return (ICases) Application.Domain.newInstance(recordIdSet);
  }

  public Cases(List<Case> sObjectList) {
    super(sObjectList);
    System.debug('Cases --- ' + Trigger.operationType);
  }

  public override void onBeforeInsert() {
    CaseProactiveServiceFunction.assignToSupportTechnicalAdvisor(Records);
    CaseSetEntitlementFunction.deriveEntitlement(Records);
    CaseSetAllMilestoneSuccessFunction.deriveMilestoneCompletedOnInsert(Records);
    CaseSetAutocloseStepsFunction.deriveAutocloseSteps(Records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    CaseMilestoneQueueable.setCompletionDateOnMilestones(Records, existingRecords);
    CaseSetEntitlementFunction.deriveEntitlement(Records);
    CaseMilestoneCompletionFunction.deriveTargetDate(Records);
    CaseQueueTransferFunction.deriveRelatedTo(Records, existingRecords);
    CaseReOpenEmailCheckboxFunction.deriveCheckboxOnUpdate(Records, existingRecords);
    CaseSetAllMilestoneSuccessFunction.deriveMilestoneCompletedOnUpdate(Records, existingRecords);
  }

  public override void onAfterInsert() {
    AbstractQueueable.enqueue(new AccountProactiveServiceQueueable(Records));
    CaseTeamMemberQueueable.addDefaultTeamMembers(Records);
    CaseSetParentERQueueable.deriveParentEROnInsert(Records);
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    AbstractQueueable.enqueue(new CaseLivingSummaryQueueable(Records, existingRecords));
    CaseTeamMemberQueueable.addDefaultTeamMembers(Records);
    CaseCreateChildCaseQueueable.createChildCases(Records, existingRecords);
    CaseFirstResponseQueueable.setCompletionDateOnMilestones(Records, existingRecords);
  }

  public override void onValidate() {
    //Collection.of(Records).mapAll(new CaseValidationFunction(null, this));
  }

  /*public override void onValidate(Map<Id, SObject> existingRecords) {
    Collection.of(Records)
      .mapAll(new CaseValidationFunction(existingRecords, this));
  }
  */
  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new Cases(sObjectList);
    }
  }
}
