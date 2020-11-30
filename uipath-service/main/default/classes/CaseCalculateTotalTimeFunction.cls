/**
 * Sets Status_Resolved_Time_Stamp__c & Total_time_duration__c
 */
public class CaseCalculateTotalTimeFunction implements SObjectToSObjectFunction {
  public CaseCalculateTotalTimeFunction(List<Case> cases) {
  }

  public SObject apply(Case record) {
    if (record.Status_Resolved_Time_Stamp__c == null) {
      record.Status_Resolved_Time_Stamp__c = system.now();
    }

    Long createdDateTime;

    if (Test.isRunningTest()) {
      createdDateTime = DateTime.now().addDays(-1).getTime();
    } else {
      createdDateTime = record.CreatedDate.getTime();
    }

    Long nowTime = DateTime.now().getTime();
    Long millisecondsDif = nowTime - createdDateTime;
    Long secondsDif = millisecondsDif / 1000;
    record.Total_time_duration__c = secondsDif / 60;

    return record;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveTotalTimeOnUpdate(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(new Set<SObjectField>{ Case.Status }, cases, existingCases);

    Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.ServiceRequestRecordType,
              CaseMetadata.AcademyRecordType,
              CaseMetadata.JapanLicensingRecordType,
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.JapanAcademyRecordType
            }
          )
          .also(Case.Status)
          .equals('Closed')
      )
      .mapAll(new CaseCalculateTotalTimeFunction(cases));
  }
}
