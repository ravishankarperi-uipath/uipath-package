public with sharing class CaseCopyFromParentERFunction implements SObjectToSObjectFunction {
  public static Map<Id, Case> parentCaseMap = new Map<Id, Case>();
  public CaseCopyFromParentERFunction(List<Case> cases) {
    Set<Id> parentIds = new Set<Id>();
    for (Case record : cases) {
      parentIds.add(record.ParentId);
    }

    for (Case parentCase : [
      SELECT
        Id,
        ContactId,
        Description,
        Issue__c,
        Priority,
        Related_To__c,
        Sub_Component__c,
        Subject,
        Actual_Result__c,
        Case_Web_Form_Region__c,
        Expected_Result__c,
        Frequency__c,
        Steps_To_Reproduce_The_Issue__c,
        What_You_Want_Us_To_Do__c,
        Workaround__c
      FROM Case
      WHERE Id IN :parentIds
    ]) {
      parentCaseMap.put(parentCase.Id, parentCase);
    }
  }

  public SObject apply(Case record) {
    if (!parentCaseMap.containsKey(record.ParentId)) {
      return null;
    }
    Case parentCase = parentCaseMap.get(record.ParentId);
    record.ContactId = parentCase.ContactId;
    record.Description = parentCase.Description;
    record.Issue__c = parentCase.Issue__c;
    record.Priority = parentCase.Priority;
    record.Related_To__c = parentCase.Related_To__c;
    record.Sub_Component__c = parentCase.Sub_Component__c;
    String parentSubject = (parentCase.Subject != null) ? parentCase.Subject : '';
    if (record.CaseNumber != null) {
      record.Subject = 'ER: ' + record.CaseNumber + ' ' + parentSubject;
    } else {
      record.Subject = 'ER: ' + CaseMetadata.CASE_NUMBER + ' ' + parentSubject;
    }
    if (record.RecordTypeId == CaseMetadata.JapanEngagementRequestRecordType) {
      record.Actual_Result__c = parentCase.Actual_Result__c;
      record.Case_Web_Form_Region__c = parentCase.Case_Web_Form_Region__c;
      record.Expected_Result__c = parentCase.Expected_Result__c;
      record.Frequency__c = parentCase.Frequency__c;
      record.Steps_To_Reproduce_The_Issue__c = parentCase.Steps_To_Reproduce_The_Issue__c;
      record.What_You_Want_Us_To_Do__c = parentCase.What_You_Want_Us_To_Do__c;
      record.Workaround__c = parentCase.Workaround__c;
    }
    return record;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveChildCaseFromParent(List<SObject> Records) {
    Collection.of(Records)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{ CaseMetadata.EngagementRequestRecordType, CaseMetadata.JapanEngagementRequestRecordType }
          )
      )
      .mapSome(
        Match.field(Case.Copy_From_Parent_Case__c)
          .hasValue()
          .also(Case.Copy_From_Parent_Case__c)
          .equals(true)
          .also(Case.Status)
          .notEquals('Closed')
          .also(Case.ParentId)
          .hasValue(),
        new CaseCopyFromParentERFunction(Records)
      );
  }

  public static void deriveChildCaseFromParent(List<SObject> Records, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Copy_From_Parent_Case__c },
      Records,
      existingCases
    );
    Collection.of(Records)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{ CaseMetadata.EngagementRequestRecordType, CaseMetadata.JapanEngagementRequestRecordType }
          )
      )
      .mapSome(
        Match.field(Case.Copy_From_Parent_Case__c)
          .hasValue()
          .also(Case.Copy_From_Parent_Case__c)
          .equals(true)
          .also(Case.Status)
          .notEquals('Closed')
          .also(Case.ParentId)
          .hasValue(),
        new CaseCopyFromParentERFunction(Records)
      );
  }
}
