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
  private static void testDeriveTotalTimeOnUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = incidentRecordTypeID, Status = 'New');

    Case updatedCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = incidentRecordTypeID, Status = 'Closed');

    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(true, updatedCase.Total_time_duration__c > 3);
    System.assertEquals(true, updatedCase.Status_Resolved_Time_Stamp__c < system.now());
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
  private static void testCaptureTimeForStatusChangeOnUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;
    Case oldCase1 = new Case(
      Id = caseId,
      Subject = 'Customer Action',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      No_of_Emails_Received__c = 2
    );
    Case updatedCase1 = new Case(
      Id = caseId,
      Subject = 'Customer Action',
      RecordTypeId = incidentRecordTypeID,
      Status = 'Customer Action',
      No_of_Emails_Received__c = 2
    );

    Case oldCase2 = new Case(Id = caseId, Subject = 'In Process', RecordTypeId = incidentRecordTypeID, Status = 'New');
    Case updatedCase2 = new Case(
      Id = caseId,
      Subject = 'In Process',
      RecordTypeId = incidentRecordTypeID,
      Status = 'In Process'
    );

    Case oldCase3 = new Case(
      Id = caseId,
      Subject = 'Pending from Engineering',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New'
    );
    Case updatedCase3 = new Case(
      Id = caseId,
      Subject = 'Pending from Engineering',
      RecordTypeId = incidentRecordTypeID,
      Status = 'Pending from Engineering'
    );

    Case oldCase4 = new Case(Id = caseId, Subject = 'Resolved', RecordTypeId = incidentRecordTypeID, Status = 'New');
    Case updatedCase4 = new Case(
      Id = caseId,
      Subject = 'Resolved',
      RecordTypeId = incidentRecordTypeID,
      Status = 'Resolved',
      No_of_Emails_Received__c = 2
    );

    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase1, updatedCase2, updatedCase3, updatedCase4 },
      new Map<Id, SObject>{
        oldCase1.Id => oldCase1,
        oldCase2.Id => oldCase2,
        oldCase3.Id => oldCase3,
        oldCase4.Id => oldCase4
      }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(2, updatedCase1.No_of_Emails_Received_for_5_days__c);
    System.assertEquals(true, updatedCase2.Status_In_Process_Time_Stamp__c <= system.now());
    System.assertEquals(true, updatedCase3.Status_Pending_Engineering_Time_Stamp__c <= system.now());
    System.assertEquals(true, updatedCase4.Status_Resolved_Time_Stamp__c <= system.now());
    System.assertEquals(2, updatedCase4.No_of_Emails_Received_for_5_days__c);
  }

  @IsTest
  private static void testCaptureTimeForStatusChangeOnInsert() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;

    List<Case> cases = new List<Case>();

    Case cs = new Case(Id = caseId, Subject = 'Test', RecordTypeId = incidentRecordTypeID, Status = 'New');

    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ cs });

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(true, cs.Start_When_New__c <= system.now());
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

  @IsTest
  private static void derivePendingTimestamps_onERCaseUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id engagementRecordTypeId = CaseMetadata.EngagementRequestRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = engagementRecordTypeId, Status = 'New');
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = engagementRecordTypeId,
      Awaiting_Pending_Reason__c = CaseMetadata.PENDING_FROM_PRODUCT
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertNotEquals(null, updatedCase.Pending_Product_Timestamp__c, 'Pending Product Timestamp is not null');
  }

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

  @IsTest
  private static void caseSubjectChangeFunction_deriveSubject() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id siRecordTypeID = CaseMetadata.ServiceIncidentRecordType;
    Case newCase = new Case(Subject = 'Test', RecordTypeId = siRecordTypeID, Status = 'New');

    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ newCase });

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals('SI: Test', newCase.Subject);
  }
}
