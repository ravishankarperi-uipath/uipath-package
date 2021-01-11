public with sharing class CaseUpdateCommValueFunction implements SObjectToSObjectFunction {
  private Map<Id, SObject> oldCases;

  public CaseUpdateCommValueFunction(List<Case> cases) {
    this.oldCases = oldCases;
  }

  public SObject apply(Case caseRecord) {
    if (
      caseRecord.RecordTypeId == CaseMetadata.AcademyRecordType ||
      caseRecord.RecordTypeId == CaseMetadata.SalesOperationRecordType ||
      caseRecord.RecordTypeId == CaseMetadata.ServiceRequestRecordType
    ) {
      caseRecord.Status = 'Customer Action';
    } else {
      caseRecord.Status = 'In Process';
    }
    caseRecord.First_Response_Time_Stamp__c = System.now();
    caseRecord.Comm_Value__c = 'FR Sent';
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveCommValue(List<Case> records) {
    Collection.of(records)
      .mapSome(
        Match.field(Case.First_Response_Time_Stamp__c)
          .equals(null)
          .also(Case.No_of_Emails_Sent__c)
          .equals(2)
          .also(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.ServiceRequestRecordType,
              CaseMetadata.EngagementRequestRecordType,
              CaseMetadata.JapanEngagementRequestRecordType,
              CaseMetadata.JapanAcademyRecordType,
              CaseMetadata.AcademyRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.JapanLicensingRecordType,
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.ServiceIncidentRecordType
            }
          ),
        new CaseUpdateCommValueFunction(records)
      );
  }
}
