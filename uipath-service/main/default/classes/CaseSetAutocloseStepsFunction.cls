public with sharing class CaseSetAutocloseStepsFunction implements SObjectToSObjectFunction {
  private Map<Id, SObject> oldCases;

  public CaseSetAutocloseStepsFunction(List<Case> cases) {
    this.oldCases = oldCases;
  }

  public SObject apply(Case caseRecord) {
    caseRecord.Solution__c = 'Autoclose Case Origin Email case';
    caseRecord.Steps_Performed__c = 'Autoclose Case Origin Email case';
    caseRecord.Resolution_Summary__c = 'Autoclose Case Origin Email case';
    caseRecord.Continue_with_Unassigned_Account__c = true;
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveAutocloseSteps(List<Case> records) {
    Collection.of(records)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.AcademyRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.ServiceRequestRecordType
            }
          )
      )
      .mapSome(
        Match.field(Case.Origin)
          .equals('Email')
          .also(Case.SuppliedEmail)
          .notIn(new Set<String>{ 'notify@ringcentral.com', 'service@ringcentral.com' }),
        new CaseSetAutocloseStepsFunction(records)
      );
  }
}
