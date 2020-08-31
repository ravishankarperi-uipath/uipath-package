public with sharing class CaseSetAllMilestoneSuccessFunction implements SObjectToSObjectFunction {
  private Map<Id, SObject> oldCases;

  public CaseSetAllMilestoneSuccessFunction(List<Case> cases) {
    this.oldCases = oldCases;
  }

  public SObject apply(Case caseRecord) {
    caseRecord.Milestone_Completed__c = true;
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveMilestoneCompletedOnUpdate(List<Case> records, Map<Id, Case> existingCases) {
    SObjectPredicate hasRecordChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Status, Case.No_of_Emails_Sent__c, Priority },
      cases,
      existingCases
    );

    Collection.of(records)
      .filter(hasRecordChanged)
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
        Match.field(Case.Status).isIn(new Set<String>{ 'Customer Action', 'In Process' }),
        new CaseSetAllMilestoneSuccessFunction(records)
      );
  }
}
