public with sharing class CaseSubjectChangeFunction implements SObjectToSObjectFunction {
  public CaseSubjectChangeFunction() {
  }

  public SObject apply(Case caseRecord) {
    if (caseRecord.RecordTypeId == CaseMetadata.ServiceIncidentRecordType) {
      caseRecord.Subject = 'SI: ' + caseRecord.Subject;
    } else {
      caseRecord.Subject = 'ER: ' + CaseMetadata.CASE_NUMBER + ' ' + caseRecord.Subject;
    }
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveSubject(List<Case> Records) {
    Collection.of(Records)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.EngagementRequestRecordType,
              CaseMetadata.JapanEngagementRequestRecordType,
              CaseMetadata.ServiceIncidentRecordType
            }
          )
      )
      .mapAll(new CaseSubjectChangeFunction());
  }
}
