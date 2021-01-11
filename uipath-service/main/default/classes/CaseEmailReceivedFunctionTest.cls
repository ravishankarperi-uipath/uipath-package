@isTest
private class CaseEmailReceivedFunctionTest {
  @IsTest
  private static void caseEmailReceivedFunction_deriveCustomerContact() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id academyId = CaseMetadata.AcademyRecordType;
    Case oldCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = academyId,
      Status = 'New',
      No_of_Emails_Received__c = 0,
      Customer_Contact__c = true
    );
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = academyId,
      Status = 'In Process',
      No_of_Emails_Received__c = 1
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(false, updatedCase.Customer_Contact__c);
  }
}
