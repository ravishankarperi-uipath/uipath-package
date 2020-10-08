/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates the Completion date on CaseMilestone for Comm Update cases
 */
public without sharing class CaseMilestoneQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private final Datetime currentDate;
  private static Boolean isAlreadyRun = false;
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
      WHERE
        CaseId IN :cases
        AND MilestoneType.Name = :Label.Communication_Milestone_Name
        AND IsCompleted = false
        AND CompletionDate = null
      FOR UPDATE
    ]) {
      milestone.CompletionDate = currentDate;
      milestoneList.add(milestone);
    }
    List<Case> casesToUpdate = new List<Case>();
    for (Case caseRecord : cases) {
      casesToUpdate.add(new Case(Id = caseRecord.Id, Comm_Update__c = false));
    }
    fflib_SObjectDomain.getTriggerEvent(Cases.class).disableAll();
    update casesToUpdate;
    update milestoneList;
    fflib_SObjectDomain.getTriggerEvent(Cases.class).enableAll();
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
      .filter(Match.field(Case.No_of_Emails_Sent__c).notEquals(2))
      .asList();

    if (!eligibleCases.isEmpty()) {
      if (!isAlreadyRun) {
        AbstractQueueable.enqueue(new CaseMilestoneQueueable(eligibleCases, System.now()));
        isAlreadyRun = true;
      }
    }
  }
}
