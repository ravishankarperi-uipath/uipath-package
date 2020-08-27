@isTest
private class CreateChildCaseQueueableTest {
  @isTest
  private static void createChildCaseQueueableTest() {
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;

    Case cs = new Case(Subject = 'Test', RecordTypeId = incidentRecordTypeID, Status = 'New', CSAT__c = 1.00);
    insert cs;
    cs.Status = 'Closed';
    cs.CSAT__c = 4.00;
    update cs;

    CreateChildCaseQueueable createChildCaseQueueable = new CreateChildCaseQueueable(new List<Case>{ cs });
    createChildCaseQueueable.execute(null);

    List<Case> children = [SELECT Id FROM Case WHERE ParentId = :cs.Id];
    System.assertEquals(1, children.size());
  }
}
