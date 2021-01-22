@isTest
public class SalesCaseBillToWOppQueueableTest {
  @isTest
  private static void testUpdateBillToOnUpdate() {
    Id legalRequestRecordTypeId = SalesCaseMetadata.LegalRequestRecordType;

    Account accountRecord = new Account(
      Name = 'New Account',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      Validation_Status__c = 'Validated',
      Sync_Status__c = 'Synced'
    );
    insert accountRecord;

    List<Opportunity> opportunities = new List<Opportunity>();
    Opportunity oppRecord1 = new Opportunity(
      Name = 'Test',
      StageName = 'Prospecting',
      CloseDate = System.today(),
      Sold_to_Partner__c = accountRecord.Id,
      Amount = 100,
      Description = 'Test description'
    );
    opportunities.add(oppRecord1);

    Opportunity oppRecord2 = new Opportunity(
      Name = 'Test',
      StageName = 'Prospecting',
      CloseDate = System.today(),
      Amount = 100,
      Description = 'Test description'
    );
    opportunities.add(oppRecord2);
    insert opportunities;

    List<Case> cases = new List<Case>();
    Case cs1 = new Case(
      Subject = 'Test',
      Opportunity__c = oppRecord1.Id,
      AccountId = accountRecord.Id,
      RecordTypeId = legalRequestRecordTypeId,
      Status = 'New'
    );
    cases.add(cs1);

    Case cs2 = new Case(
      Subject = 'Test',
      Opportunity__c = oppRecord2.Id,
      AccountId = accountRecord.Id,
      RecordTypeId = legalRequestRecordTypeId,
      Status = 'New'
    );
    cases.add(cs2);
    insert cases;

    Test.StartTest();

    SalesCaseBillToWOppQueueable salesCaseBillToWOppQueueable = new SalesCaseBillToWOppQueueable(
      new List<Case>{ cs1, cs2 }
    );
    salesCaseBillToWOppQueueable.execute(null);

    List<Case> caseRecord = [SELECT Id, Bill_To__r.Name FROM Case WHERE Id = :cs1.Id OR Id = :cs2.Id LIMIT 2];
    System.assertEquals('New Account', caseRecord[0].Bill_To__r.Name);
    System.assertEquals('New Account', caseRecord[1].Bill_To__r.Name);
    Test.StopTest();
  }
}
