public with sharing class CaseCaptureFRFunction implements SObjectToSObjectFunction {
  private Map<Id, SObject> oldCases;

  public CaseCaptureFRFunction(List<Case> cases) {
    this.oldCases = oldCases;
  }

  public SObject apply(Case caseRecord) {
    caseRecord.First_Response_Sent__c = true;
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveCaptureFR(List<Case> records) {
    Collection.of(records)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.AcademyRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.ServiceRequestRecordType,
              CaseMetadata.EngagementRequestRecordType,
              CaseMetadata.JapanAcademyRecordType,
              CaseMetadata.JapanLicensingRecordType,
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.JapanEngagementRequestRecordType
            }
          )
      )
      .mapSome(
        Match.field(Case.First_Response_Time_Stamp__c).equals(null).also(Case.No_of_Emails_Sent__c).equals(2),
        new CaseCaptureFRFunction(records)
      );
  }
}
