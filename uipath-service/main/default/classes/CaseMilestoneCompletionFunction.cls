public with sharing class CaseMilestoneCompletionFunction implements SObjectToSObjectFunction {
  private Map<Id, CaseMilestone> caseMilestoneMap;

  public CaseMilestoneCompletionFunction(List<Case> cases) {
    caseMilestoneMap = new Map<Id, CaseMilestone>(
      [SELECT Id, TargetDate FROM CaseMilestone WHERE CaseId IN :cases AND IsCompleted = false ORDER BY TargetDate ASC]
    );
  }

  public SObject apply(Case caseRecord) {
    caseRecord.Milestone_Completed__c = (caseMilestoneMap.get(caseRecord.Id) == null);
    if (!caseRecord.Milestone_Completed__c) {
      caseRecord.Milestone_Target_Date__c = caseMilestoneMap.get(caseRecord.Id).TargetDate;
    }
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
