/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates the target date on case for milestones
 */
public without sharing class CaseMilestoneCompletionQueueable extends AbstractQueueable {
  private final List<Case> cases;

  public CaseMilestoneCompletionQueueable(List<Case> cases) {
    super('CaseMilestoneCompletionQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.updateTargetDate(cases);
  }

  private void updateTargetDate(List<Case> cases) {
    Map<Id, CaseMilestone> caseMilestoneMap = new Map<Id, CaseMilestone>();
    for (CaseMilestone milestone : [
      SELECT Id, CaseId, TargetDate
      FROM CaseMilestone
      WHERE CaseId IN :cases AND IsCompleted = false
      ORDER BY TargetDate ASC
    ]) {
      if (!caseMilestoneMap.containsKey(milestone.CaseId)) {
        caseMilestoneMap.put(milestone.CaseId, milestone);
      }
    }
    List<Case> casesToUpdate = new List<Case>();
    for (Case caseRecord : cases) {
      Case caseToUpdate = new Case(Id = caseRecord.Id, Milestone_Completed__c = true, Milestone_Target_Date__c = null);
      if (caseMilestoneMap.containsKey(caseRecord.Id)) {
        caseToUpdate.Milestone_Completed__c = false;
        caseToUpdate.Milestone_Target_Date__c = caseMilestoneMap.get(caseRecord.Id).TargetDate;
      }
      casesToUpdate.add(caseToUpdate);
    }
    fflib_SObjectDomain.getTriggerEvent(Cases.class).disableAll();
    update casesToUpdate;
    fflib_SObjectDomain.getTriggerEvent(Cases.class).enableAll();
  }

  public static void setTargetDate(List<Case> records, Map<Id, SObject> existingRecords) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Milestone_Completed__c },
      records,
      existingRecords
    );
    List<Case> eligibleCases = (List<Case>) Collection.of(records)
      //.filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.ServiceRequestRecordType,
              CaseMetadata.EngagementRequestRecordType,
              CaseMetadata.JapanEngagementRequestRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.AcademyRecordType,
              CaseMetadata.JapanAcademyRecordType,
              CaseMetadata.JapanLicensingRecordType,
              CaseMetadata.JapanIncidentRecordType
            }
          )
      )
      .filter(
        Match.field(Case.Status)
          .notEquals('Closed')
          .also(Case.Milestone_Completed__c)
          .hasValue()
          .also(Case.Milestone_Completed__c)
          .equals(true)
      )
      .asList();
    if (!eligibleCases.isEmpty()) {
      AbstractQueueable.enqueue(new CaseMilestoneCompletionQueueable(eligibleCases));
    }
  }
}
