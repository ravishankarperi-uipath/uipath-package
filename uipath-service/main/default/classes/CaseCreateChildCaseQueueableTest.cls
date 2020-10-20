@isTest
private class CaseCreateChildCaseQueueableTest {
  @isTest
  private static void createChildCaseQueueableTest() {
    Id incidentRecordTypeID = CaseMetadata.IncidentRecordType;

    User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(testUser) {
      Group grp = new Group(Name = 'Product_Support_Queue', type = 'Queue');
      insert grp;
      QueuesObject queue = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
      insert queue;
    }

    Case cs = new Case(Subject = 'Test', RecordTypeId = incidentRecordTypeID, Status = 'New', CSAT__c = 1.00);
    insert cs;
    cs.Status = 'Closed';
    cs.Closure_Classification__c = '3rd Party not under support scope';
    cs.CSAT__c = 4.00;
    update cs;

    CaseCreateChildCaseQueueable createChildCaseQueueable = new CaseCreateChildCaseQueueable(new List<Case>{ cs });
    createChildCaseQueueable.execute(null);

    List<Case> children = [SELECT Id FROM Case WHERE ParentId = :cs.Id];
    System.assertEquals(1, children.size());
  }
}
