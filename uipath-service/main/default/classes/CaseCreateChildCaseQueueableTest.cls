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

    Account a1 = new Account(
      Name = 'NewAccountABC',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      LD_USE_DnB_Optimize__c = false
    );
    insert a1;

    Contact con = new Contact(
      FirstName = 'Testadasda',
      LastName = 'Test',
      Email = 'asdasdad.test@test.com',
      AccountId = a1.Id,
      MailingCountry = 'Australia',
      MailingState = '',
      Title = 'Test',
      LeadSource = 'Webinar'
    );
    insert con;

    Case cs = new Case(Subject = 'Test', RecordTypeId = incidentRecordTypeID, Status = 'New', CSAT__c = 1.00);
    insert cs;
    cs.Status = 'Closed';
    cs.Closure_Classification__c = '3rd Party not under support scope';
    cs.Related_To__c = 'AI Fabric';
    cs.Sub_Component__c = 'Others';
    cs.Solution__c = 'No solution. This is a test.';
    cs.SuppliedEmail = 'asdasdad.test@test.com';
    cs.ContactId = con.Id;
    cs.CSAT__c = 4.00;
    update cs;

    CaseCreateChildCaseQueueable createChildCaseQueueable = new CaseCreateChildCaseQueueable(new List<Case>{ cs });
    createChildCaseQueueable.execute(null);

    List<Case> children = [SELECT Id FROM Case WHERE ParentId = :cs.Id];
    System.assertEquals(1, children.size());
  }
}
