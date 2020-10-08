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
    this.Configuration.disableTriggerCRUDSecurity();
  }

  public override void onBeforeInsert() {
    CaseProactiveServiceFunction.assignToSupportTechnicalAdvisor(Records);
    CaseSetEntitlementFunction.deriveEntitlement(Records);
    CaseSetAllMilestoneSuccessFunction.deriveMilestoneCompletedOnInsert(Records);
    CaseSetAutocloseStepsFunction.deriveAutocloseSteps(Records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    CaseSetEntitlementFunction.deriveEntitlement(Records);
    CaseQueueTransferFunction.deriveRelatedTo(Records, existingRecords);
    CaseReOpenEmailCheckboxFunction.deriveCheckboxOnUpdate(Records, existingRecords);

    CaseSetAllMilestoneSuccessFunction.deriveMilestoneCompletedOnUpdate(Records, existingRecords);
  }

  public override void onAfterInsert() {
    CaseTeamMemberQueueable.addDefaultTeamMembers(Records);
    CaseSetParentERQueueable.deriveParentEROnInsert(Records);
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    AbstractQueueable.enqueue(new CaseLivingSummaryQueueable(Records, existingRecords));
    CaseTeamMemberQueueable.addDefaultTeamMembers(Records);
    CaseCreateChildCaseQueueable.createChildCases(Records, existingRecords);

    CaseMilestoneCompletionQueueable.setTargetDate(Records, existingRecords);
    CaseMilestoneQueueable.setCompletionDateOnMilestones(Records, existingRecords);
    CaseFirstResponseQueueable.setCompletionDateOnMilestones(Records, existingRecords);
  }

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new Cases(sObjectList);
    }
  }
}
