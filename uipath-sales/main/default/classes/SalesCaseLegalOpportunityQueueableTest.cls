@IsTest
public class SalesCaseLegalOpportunityQueueableTest {
  @TestSetup
  static void makeData() {
    Opportunity opp = new Opportunity(Name = 'Deal');
    opp.CurrencyISOCode = 'JPY';
    opp.StageName = 'In Progress';
    opp.CloseDate = System.today() + 10;
    insert opp;
  }

  @IsTest
  private static void whenNewLegalCaseIsCreatedOrDeleted_CountIsUpdated() {
    Opportunity opp = [SELECT Id, Number_of_Legal_Cases__c FROM Opportunity LIMIT 1];
    System.assertEquals(0, opp.Number_of_Legal_Cases__c, 'Legal Case count should be blank');
    Id legalRecordType = SalesCaseMetadata.LegalRequestRecordType;
    Case legalCase = new Case(
      Subject = 'Test',
      RecordTypeId = legalRecordType,
      Opportunity__c = opp.Id,
      Status = 'New'
    );

    insert legalCase;
    new SalesCaseLegalOpportunityQueueable(new List<Case>{ legalCase }).work();
    opp = [SELECT Id, Number_of_Legal_Cases__c FROM Opportunity LIMIT 1];
    System.assertEquals(1, opp.Number_of_Legal_Cases__c, 'Legal Case count is not updated');

    delete legalCase;
    new SalesCaseLegalOpportunityQueueable(new List<Case>{ legalCase }).work();
    opp = [SELECT Id, Number_of_Legal_Cases__c FROM Opportunity LIMIT 1];
    System.assertEquals(0, opp.Number_of_Legal_Cases__c, 'Legal Case count is not updated');
  }
}
