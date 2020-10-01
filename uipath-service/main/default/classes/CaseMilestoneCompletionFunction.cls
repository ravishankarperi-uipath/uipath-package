public with sharing class CaseMilestoneCompletionFunction implements SObjectToSObjectFunction {
  private Map<Id, CaseMilestone> caseMilestoneMap;

  public CaseMilestoneCompletionFunction(List<Case> cases) {
    caseMilestoneMap = new Map<Id, CaseMilestone>();
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
  }

  public SObject apply(Case caseRecord) {
    caseRecord.Milestone_Completed__c = (caseMilestoneMap.containsKey(caseRecord.Id)) ? false : true;
    caseRecord.Milestone_Target_Date__c = (caseMilestoneMap.containsKey(caseRecord.Id))
      ? caseMilestoneMap.get(caseRecord.Id).TargetDate
      : null;
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveTargetDate(List<Case> records) {
    Collection.of(records)
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
      .mapSome(
        Match.field(Case.Status)
          .notEquals('Closed')
          .also(Case.Milestone_Completed__c)
          .hasValue()
          .also(Case.Milestone_Completed__c)
          .equals(true),
        new CaseMilestoneCompletionFunction(records)
      );
  }
}
