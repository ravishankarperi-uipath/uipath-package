@IsTest
public class CaseCalculateTotalTimeFunctionTest {
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
}
