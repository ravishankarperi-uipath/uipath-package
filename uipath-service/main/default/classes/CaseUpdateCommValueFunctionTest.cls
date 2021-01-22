@isTest
public class CaseUpdateCommValueFunctionTest {
  @IsTest
  private static void testDeriveCommValueOnUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;
    Id academyRecordTypeID = CaseMetadata.AcademyRecordType;
    Case oldCase1 = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 1
    );

    Case updatedCase1 = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 2
    );

    Case oldCase2 = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = academyRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 1
    );
    Case updatedCase2 = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = academyRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 2
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase1, updatedCase2 },
      new Map<Id, SObject>{ oldCase1.Id => oldCase1, oldCase2.Id => oldCase2 }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals('FR Sent', updatedCase1.Comm_Value__c);
    System.assertEquals('In Process', updatedCase1.Status);
    System.assertEquals('FR Sent', updatedCase2.Comm_Value__c);
    System.assertEquals('Customer Action', updatedCase2.Status);
  }

  @IsTest
  private static void testDeriveCommValueOnInsert() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;
    Id academyRecordTypeID = CaseMetadata.AcademyRecordType;
    Case cs1 = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = incidentRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 2
    );

    Case cs2 = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = academyRecordTypeID,
      Status = 'New',
      No_of_Emails_Sent__c = 2
    );

    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ cs1, cs2 });

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals('FR Sent', cs1.Comm_Value__c);
    System.assertEquals('In Process', cs1.Status);
    System.assertEquals('FR Sent', cs2.Comm_Value__c);
    System.assertEquals('Customer Action', cs2.Status);
  }
}
