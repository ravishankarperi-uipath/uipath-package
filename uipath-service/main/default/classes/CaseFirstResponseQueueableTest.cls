@IsTest
public class CaseFirstResponseQueueableTest {
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

  static testMethod void updateMilestones_insertCase() {    
      Case incidentCase = new Case();
      incidentCase.RecordTypeId = CaseMetadata.IncidentRecordType;
      incidentCase.Subject = 'Incident  Case';
      incidentCase.Status = 'New';      
      incidentCase.No_of_Emails_Sent__c = 1;
      insert incidentCase;
      Test.startTest();
      incidentCase.No_of_Emails_Sent__c = 2;
      update incidentCase;
      new CaseFirstResponseQueueable(new List<Case>{ incidentCase }).execute(null);
      Test.stopTest();
      List<CaseMilestone> milestones = [SELECT Id, CompletionDate FROM CaseMilestone];
  }
}
