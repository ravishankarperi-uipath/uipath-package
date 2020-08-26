/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates the Completion date on CaseMilestone for Comm Update cases
 */
public with sharing class CaseMilestoneQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private final Map<Id, SObject> oldCasessMap;
  public CaseMilestoneQueueable(List<SObject> cases, Map<Id, SObject> oldCasessMap) {
    super('CaseMilestoneQueueable');
    this.cases = cases;
    this.oldCasessMap = oldCasessMap;
  }

  public override void work() {
    System.debug('CaseMilestoneQueueable work');
    this.updateMilestones(cases);
  }

  private void updateMilestones(List<Case> cases) {
    for (Case caseRecord : cases) {
      caseRecord.Comm_Update__c = false;
    }
    List<CaseMilestone> milestoneList = new List<CaseMilestone>();
    for (CaseMilestone milestone : [
      SELECT Id, CompletionDate
      FROM CaseMilestone
      WHERE CaseId IN :cases AND MilestoneType.Name = :Label.Communication_Milestone_Name AND IsCompleted = false
      FOR UPDATE
    ]) {
      milestone.CompletionDate = System.today();
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
      AbstractQueueable.enqueue(new CaseMilestoneQueueable(eligibleCases, null));
    }
  }
}
