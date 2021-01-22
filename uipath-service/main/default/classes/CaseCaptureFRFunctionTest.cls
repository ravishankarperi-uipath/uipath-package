@IsTest
public class CaseCaptureFRFunctionTest {
  @IsTest
  private static void testDeriveCaptureFROnInsert() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id engagementRecordTypeID = CaseMetadata.EngagementRequestRecordType;

    Case cs = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = engagementRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 2
    );

    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ cs });

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(true, cs.First_Response_Sent__c);
  }

  private static void testDeriveCaptureFROnUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;
    Case oldCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 1
    );
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 2
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(true, updatedCase.First_Response_Sent__c);
  }
}
