@IsTest
public class CaseLivingSummaryQueueableTest {
  @TestSetup
  static void makeData() {
    Account account = new Account(Name = 'John');
    account.BillingStreet = 'Test Street';
    account.BillingCity = 'Test City';
    account.BillingPostalCode = 'SW1 3DWW';
    account.BillingCountry = 'United Kingdom';
    account.Phone = '1234567890';
    account.Industry = 'Others';
    insert account;
    Entitlement entitlement = new Entitlement();
    entitlement.AccountId = account.Id;
    entitlement.Name = 'Standard Account';
    insert entitlement;
  }

  static testMethod void createLivingSummaryHistory_onUpdateCase() {
    Case incidentCase = new Case();
    incidentCase.RecordTypeId = CaseMetadata.IncidentRecordType;
    incidentCase.Subject = 'Incident  Case';
    incidentCase.Status = 'New';
    incidentCase.Problem__c = 'Some Problem';
    incidentCase.Cause__c = 'Some Cause';
    insert incidentCase;
    Map<Id, Case> existingCases = new Map<Id, Case>(
      [SELECT Id, Problem__c, Cause__c, Validation__c, Solution__c, Solution_Instructions__c FROM Case LIMIT 1]
    );
    incidentCase.Problem__c = 'Updated Problem';
    incidentCase.Cause__c = 'Updated Cause';
    update incidentCase;
    Test.startTest();
    System.debug('### Comm_Update__c ' + incidentCase);
    new CaseLivingSummaryQueueable(new List<Case>{ incidentCase }, existingCases).work();
    Test.stopTest();
    List<Living_Summary_History__c> summaryHistory = [SELECT Id FROM Living_Summary_History__c];
    System.assertEquals(2, summaryHistory.size(), 'Expecting Living Summary History to be created');
  }
}
