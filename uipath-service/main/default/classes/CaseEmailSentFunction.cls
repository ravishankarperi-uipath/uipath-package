public with sharing class CaseEmailSentFunction implements SObjectToSObjectFunction {
  private Map<Id, Case> parentCaseMap;
  private final Set<String> ORIGIN_EMAIL_SENT;
  public CaseEmailSentFunction(List<Case> cases) {
    ORIGIN_EMAIL_SENT = new Set<String>();
    ORIGIN_EMAIL_SENT.add('Web');
    ORIGIN_EMAIL_SENT.add('Phone');
    ORIGIN_EMAIL_SENT.add('Select One');
    ORIGIN_EMAIL_SENT.add('Internally - On behalf of customer');
  }

  public SObject apply(Case caseRecord) {
    if (UserInfo.getUserType() != 'Standard') {
      return caseRecord;
    }
    if (
      String.isNotBlank(caseRecord.Subject) && caseRecord.Subject.contains('Follow Up') ||
      ORIGIN_EMAIL_SENT.contains(caseRecord.Origin)
    ) {
      caseRecord.No_of_Emails_Sent__c = 1;
    }

    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void incrementEmailCount(List<Case> records) {
    Collection.of(records)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.AcademyRecordType,
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.JapanAcademyRecordType,
              CaseMetadata.JapanLicensingRecordType
            }
          )
          .also(Case.ContactId)
          .hasValue()
          .also(Case.Status)
          .equals('New')
      )
      .mapAll(new CaseEmailSentFunction(records));
  }
}
