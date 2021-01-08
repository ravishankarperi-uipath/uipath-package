@IsTest
public class CaseCopyFromParentERFunctionTest {
  @IsTest
  private static void deriveChildCaseFromParent_onERCaseUpdate() {
    Id engagementRecordTypeId = CaseMetadata.JapanEngagementRequestRecordType;
    Case parentCase = new Case(
      Subject = 'Parent',
      RecordTypeId = CaseMetadata.JapanIncidentRecordType,
      Status = 'New',
      Description = 'Parent Case'
    );

    Case oldCase = new Case(
      Subject = 'Child',
      RecordTypeId = engagementRecordTypeId,
      Status = 'New',
      Description = 'Child Case'
    );
    List<Case> casesToInsert = new List<Case>{ parentCase, oldCase };
    insert casesToInsert;

    Case updatedCase = new Case(
      Id = casesToInsert.get(1).Id,
      ParentId = casesToInsert.get(0).Id,
      Subject = 'Test',
      RecordTypeId = engagementRecordTypeId,
      Copy_From_Parent_Case__c = true
    );

    oldCase.ParentId = casesToInsert.get(0).Id;

    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ updatedCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(parentCase.Description, updatedCase.Description, 'Description is not updated');
    System.assertEquals(
      'ER: ' +
      CaseMetadata.CASE_NUMBER +
      ' ' +
      parentCase.Subject,
      updatedCase.Subject,
      'Subject is not updated'
    );

    updatedCase = [SELECT Id, Subject, CaseNumber FROM Case WHERE Id = :updatedCase.Id];
    updatedCase.Subject = 'ER: ' + CaseMetadata.CASE_NUMBER + ' ' + parentCase.Subject;
    new CaseERSubjectQueueable(new List<Case>{ updatedCase }).work();
    updatedCase = [SELECT Id, Subject, CaseNumber FROM Case WHERE Id = :updatedCase.Id];
    System.assertEquals(
      'ER: ' +
      updatedCase.CaseNumber +
      ' ' +
      parentCase.Subject,
      updatedCase.Subject,
      'Subject is not updated'
    );
  }
}
