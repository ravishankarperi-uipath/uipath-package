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

  public class StatusORFieldsChanged implements SObjectPredicate {
    Map<Id, SObject> changedRecords = new Map<Id, SObject>();

    public StatusORFieldsChanged(
      Set<Schema.SObjectField> fieldTokens,
      List<SObject> records,
      Map<Id, SObject> existingRecords
    ) {
      for (SObject newRecord : Records) {
        Id recordId = (Id) newRecord.get('Id');
        if (existingRecords == null || !existingRecords.containsKey(recordId)) {
          continue;
        }
        SObject oldRecord = existingRecords.get(recordId);
        for (Schema.SObjectField fieldToken : fieldTokens) {
          if (
            fieldToken != Case.Status ||
            (fieldToken == Case.Status &&
            (newRecord.get(fieldToken) == 'In Process' ||
            newRecord.get(fieldToken) == 'Customer Action'))
          ) {
            if (oldRecord.get(fieldToken) != newRecord.get(fieldToken)) {
              changedRecords.put(newRecord.Id, newRecord);
              break; // prevents the records from being added multiple times
            }
          }
        }
      }
    }

    public Boolean apply(SObject record) {
      return changedRecords.containsKey(record.Id);
    }
  }

  public static void deriveMilestoneCompletedOnUpdate(List<SObject> cases, Map<Id, SObject> existingCases) {
    StatusORFieldsChanged StatusORFieldsChanged = new StatusORFieldsChanged(
      new Set<SObjectField>{ Case.Status, Case.No_of_Emails_Sent__c, Case.Priority },
      cases,
      existingCases
    );

    Collection.of(cases)
      .filter(StatusORFieldsChanged)
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
      .mapAll(new CaseSetAllMilestoneSuccessFunction(cases));
  }

  public static void deriveMilestoneCompletedOnInsert(List<Case> records) {
    Collection.of(records)
      .mapSome(
        Match.field(Case.Status)
          .equals('New')
          .also(Case.RecordTypeId)
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
          ),
        new CaseSetAllMilestoneSuccessFunction(records)
      );
  }
}
