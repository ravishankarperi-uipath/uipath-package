/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates the Completion date on CaseMilestone for Comm Update cases
 */
public with sharing class CaseMilestoneQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private final Datetime currentDate;
  public CaseMilestoneQueueable(List<SObject> cases, Datetime currentDate) {
    super('CaseMilestoneQueueable');
    this.cases = cases;
    this.currentDate = currentDate;
  }

  public override void work() {
    this.updateMilestones(cases);
  }

  private void updateMilestones(List<Case> cases) {
    List<CaseMilestone> milestoneList = new List<CaseMilestone>();
    for (CaseMilestone milestone : [
      SELECT Id, CompletionDate
      FROM CaseMilestone
      WHERE CaseId IN :cases AND MilestoneType.Name = :Label.Communication_Milestone_Name AND IsCompleted = false
      FOR UPDATE
    ]) {
      milestone.CompletionDate = currentDate;
      milestoneList.add(milestone);
    }
    update milestoneList;
  }

  public static void setCompletionDateOnMilestones(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Comm_Update__c },
      cases,
      existingCases
    );

    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.AcademyRecordType,
              CaseMetadata.IncidentRecordType,
              CaseMetadata.JapanAcademyRecordType,
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.JapanLicensingRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.ServiceRequestRecordType
            }
          )
          .also(Case.Comm_Update__c)
          .equals(true)
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      for (Case caseRecord : eligibleCases) {
        caseRecord.Comm_Update__c = false;
      }
      AbstractQueueable.enqueue(new CaseMilestoneQueueable(eligibleCases, System.now()));
    }
  }
}
