@IsTest
public class CaseSetAutocloseStepsFunctionTest {
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
}
