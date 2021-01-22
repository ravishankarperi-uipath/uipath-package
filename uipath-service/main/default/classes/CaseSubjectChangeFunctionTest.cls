@IsTest
public class CaseSubjectChangeFunctionTest {
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
