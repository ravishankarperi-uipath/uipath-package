/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates the Completion date on CaseMilestone for First Response cases
 */
public with sharing class CaseFirstResponseQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private final Datetime currentTime;

  public CaseFirstResponseQueueable(List<SObject> cases, Datetime currentTime) {
    super('CaseFirstResponseQueueable');
    this.cases = cases;
    this.currentTime = currentTime;
  }

  public override void work() {
    this.updateMilestones(cases);
  }

  private void updateMilestones(List<Case> cases) {
    List<CaseMilestone> milestoneList = new List<CaseMilestone>();
    for (CaseMilestone milestone : [
      SELECT Id, CompletionDate
      FROM CaseMilestone
      WHERE CaseId IN :cases AND MilestoneType.Name = 'First Response' AND IsCompleted = false AND CompletionDate = null
      FOR UPDATE
    ]) {
      milestone.CompletionDate = currentTime;
      milestoneList.add(milestone);
    }
    fflib_SObjectDomain.getTriggerEvent(Cases.class).disableAll();
    update milestoneList;
    fflib_SObjectDomain.getTriggerEvent(Cases.class).enableAll();
  }

  public static void setCompletionDateOnMilestones(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.No_of_Emails_Sent__c },
      cases,
      existingCases
    );

    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(hasChanged)
      .filter(Match.field(Case.No_of_Emails_Sent__c).equals(2))
      .asList();

    if (!eligibleCases.isEmpty()) {
      AbstractQueueable.enqueue(new CaseFirstResponseQueueable(eligibleCases, System.now()));
    }
  }
}
