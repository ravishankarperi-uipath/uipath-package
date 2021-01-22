@IsTest
public class CaseReOpenEmailCheckboxFunctionTest {
  @IsTest
  private static void testClosedCheckBoxOnUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;
    Case oldCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      No_of_Emails_Received__c = 0,
      IsClosed_NotifyOnMail__c = false
    );
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'Closed',
      No_of_Emails_Received__c = 2,
      IsClosed_NotifyOnMail__c = false
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(true, updatedCase.IsClosed_NotifyOnMail__c);
  }
}
