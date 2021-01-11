public with sharing class CaseReOpenFunction implements SObjectToSObjectFunction {
  private Map<Id, SObject> oldCases;

  public CaseReOpenFunction(List<Case> cases) {
    this.oldCases = oldCases;
  }

  public SObject apply(Case caseRecord) {
    caseRecord.Case_Re_Open_Date__c = system.today();
    caseRecord.Reopen__c = true;
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveCaseReOpen(List<SObject> cases, Map<Id, SObject> existingCases) {
    HasRecordChanged hasRecordChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.No_of_Emails_Received__c },
      cases,
      existingCases
    );

    Collection.of(cases)
      .filter(HasRecordChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.ServiceRequestRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.AcademyRecordType,
              CaseMetadata.JapanAcademyRecordType,
              CaseMetadata.JapanLicensingRecordType,
              CaseMetadata.JapanIncidentRecordType
            }
          )
      )
      .mapSome(Match.field(Case.Status).equals('Resolved'), new CaseReOpenFunction(cases));
  }
}
