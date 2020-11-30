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
    CaseSubjectChangeFunction.deriveSubject(Records);
    CaseProactiveServiceFunction.assignToSupportTechnicalAdvisor(Records);
    CaseSetEntitlementFunction.deriveEntitlement(Records);
    CaseSetAllMilestoneSuccessFunction.deriveMilestoneCompletedOnInsert(Records);
    CaseCopyFromParentERFunction.deriveChildCaseFromParent(Records);
    CaseSetAutocloseStepsFunction.deriveAutocloseSteps(Records);
    CaseCaptureFRFunction.deriveCaptureFR(Records);
    CaseEmailSentFunction.incrementEmailCount(Records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    CaseSetEntitlementFunction.deriveEntitlement(Records);
    CaseQueueTransferFunction.deriveRelatedTo(Records, existingRecords);
    CaseReOpenEmailCheckboxFunction.deriveCheckboxOnUpdate(Records, existingRecords);
    CaseSetAllMilestoneSuccessFunction.deriveMilestoneCompletedOnUpdate(Records, existingRecords);
    CaseCalculateTotalTimeFunction.deriveTotalTimeOnUpdate(Records, existingRecords);
    CaseCaptureFRFunction.deriveCaptureFR(Records);
    CasePendingReasonChangeFunction.derivePendingTimestamps(Records, existingRecords);
    CaseCopyFromParentERFunction.deriveChildCaseFromParent(Records, existingRecords);
    CaseFirstResponseOnERQueueable.setChildCaseUpdateNotification(Records, existingRecords);
  }

  public override void onAfterInsert() {
    CaseTeamMemberQueueable.addDefaultTeamMembers(Records);
    CaseSetParentERQueueable.deriveParentEROnInsert(Records);
    CaseERSubjectQueueable.setCaseNumberOnSubject(Records);
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    AbstractQueueable.enqueue(new CaseLivingSummaryQueueable(Records, existingRecords));
    CaseTeamMemberQueueable.addDefaultTeamMembers(Records);
    CaseCreateChildCaseQueueable.createChildCases(Records, existingRecords);
    CaseMilestoneQueueable.setCompletionDateOnMilestones(Records, existingRecords);
    CaseFirstResponseQueueable.setCompletionDateOnMilestones(Records, existingRecords);
    CaseMilestoneCompletionQueueable.setTargetDate(Records, existingRecords);
    CaseL2ResolutionChangeOnERQueueable.setChildCaseUpdateNotificationOnParent(Records, existingRecords);
    CaseStatusChangeOnERQueueable.setChildCaseUpdateNotification(Records, existingRecords);
    CaseOwnerChangeOnERQueueable.setChildCaseUpdateNotificationOnParent(Records, existingRecords);
  }

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new Cases(sObjectList);
    }
  }
}
