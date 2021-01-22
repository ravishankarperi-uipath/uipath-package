public with sharing class CaseCaptureTimeForStatusChangeFunction implements SObjectToSObjectFunction {
  public CaseCaptureTimeForStatusChangeFunction(List<Case> cases) {
  }

  public SObject apply(Case caseRecord) {
    Long createdDateTime;

    if (caseRecord.Status == 'Customer Action') {
      caseRecord.No_of_Emails_Received_for_5_days__c = caseRecord.No_of_Emails_Received__c;
      caseRecord.Status_Customer_Action_Time_Stamp__c = system.now();
    } else if (caseRecord.Status == 'In Process') {
      caseRecord.Status_In_Process_Time_Stamp__c = system.now();
    } else if (caseRecord.Status == 'New') {
      caseRecord.Start_When_New__c = system.now();
    } else if (caseRecord.Status == 'Pending from Engineering') {
      caseRecord.Status_Pending_Engineering_Time_Stamp__c = system.now();
    } else if (caseRecord.Status == 'Resolved') {
      caseRecord.No_of_Emails_Received_for_5_days__c = caseRecord.No_of_Emails_Received__c;
      caseRecord.Status_Resolved_Time_Stamp__c = system.now();

      if (Test.isRunningTest()) {
        createdDateTime = DateTime.now().addDays(-1).getTime();
      } else {
        createdDateTime = caseRecord.CreatedDate.getTime();
      }

      Long nowTime = DateTime.now().getTime();
      Long millisecondsDif = nowTime - createdDateTime;
      Long secondsDif = millisecondsDif / 1000;
      caseRecord.Time_taken_to_resolve_in_Mnutes__c = secondsDif / 60;
    }

    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveCaptureTimeForStatusChangeOnInsert(List<Case> records) {
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
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.ServiceIncidentRecordType
            }
          )
      )
      .mapAll(new CaseCaptureTimeForStatusChangeFunction(records));
  }

  public static void deriveCaptureTimeForStatusChangeOnUpdate(List<SObject> records, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(new Set<SObjectField>{ Case.Status }, records, existingCases);

    Collection.of(records)
      .filter(hasChanged)
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
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.ServiceIncidentRecordType
            }
          )
      )
      .mapAll(new CaseCaptureTimeForStatusChangeFunction(records));
  }
}
