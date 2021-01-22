@IsTest
public class CasePendingReasonChangeFunctionTest {
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
}
