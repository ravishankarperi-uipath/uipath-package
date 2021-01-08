@IsTest
public class CaseCaptTimeForStatusChangeFunctionTest {
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
}
