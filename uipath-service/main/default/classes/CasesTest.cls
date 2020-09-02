@IsTest
public class CasesTest {
  @IsTest
  private static void testCreateChildCases() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;
    Case oldCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      CSAT__c = 1.00
    );
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'Closed',
      CSAT__c = 4.00
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals('Closed', updatedCase.Status);
  }

  @IsTest
  private static void testDeriveParentEROnInsert() {
    Id parentId = fflib_IDGenerator.generate(Case.SObjectType);
    Id childId = fflib_IDGenerator.generate(Case.SObjectType);
    Id engagementRecordTypeID = CaseMetadata.EngagementRequestRecordType;

    Case parent = new Case(
      Id = parentId,
      Subject = 'Parent',
      RecordTypeId = engagementRecordTypeID,
      Status = 'New',
      Has_ER__c = false
    );
    Case child = new Case(
      Id = childId,
      ParentId = parentId,
      Subject = 'Child',
      RecordTypeId = engagementRecordTypeID,
      Status = 'New'
    );
    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ child });

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(false, parent.Has_ER__c);
  }

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

  @IsTest
  private static void testDeriveMilestoneCompletedOnInsert() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;

    Case cs = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      Milestone_Completed__c = false
    );

    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ cs });

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(true, cs.Milestone_Completed__c);
  }

  @IsTest
  private static void testSetAutocloseStepsFunction() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;

    Case cs = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      Origin = 'Email'
    );

    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ cs });

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(true, cs.Continue_with_Unassigned_Account__c);
    System.assertEquals('Autoclose Case Origin Email case', cs.Solution__c);
    System.assertEquals('Autoclose Case Origin Email case', cs.Steps_Performed__c);
    System.assertEquals('Autoclose Case Origin Email case', cs.Resolution_Summary__c);
  }

  @IsTest
  private static void testDeriveMilestoneCompletedOnUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = incidentRecordTypeID, Status = 'New');
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'In Process'
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(true, updatedCase.Milestone_Completed__c);
  }
}
