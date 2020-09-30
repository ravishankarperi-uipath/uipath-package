@IsTest
public class CaseMilestoneQueueableTest {
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

  static testMethod void setCompletionDateOnMilestones_onUpdateCase() {
    Case incidentCase = new Case();
    incidentCase.RecordTypeId = CaseMetadata.IncidentRecordType;
    incidentCase.Subject = 'Incident  Case';
    incidentCase.Status = 'New';
    insert incidentCase;
    Map<Id, Case> existingCases = new Map<Id, Case>([SELECT Id, Comm_Update__c FROM Case LIMIT 1]);
    incidentCase.Comm_Update__c = true;
    update incidentCase;
    Test.startTest();
    CaseMilestoneQueueable.setCompletionDateOnMilestones(new List<Case>{ incidentCase }, existingCases);
    Test.stopTest();
    List<CaseMilestone> milestones = [SELECT Id, CompletionDate FROM CaseMilestone];
  }
}
