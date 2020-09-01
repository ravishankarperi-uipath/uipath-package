@isTest
public class CaseTeamMemberQueueableTest {
  @TestSetup
  static void makeData() {
    CaseTeamRole csmTeamRole = new CaseTeamRole();
    csmTeamRole.Name = CaseMetadata.CSM_ROLE;
    csmTeamRole.AccessLevel = 'Read';
    CaseTeamRole ctmTeamRole = new CaseTeamRole();
    ctmTeamRole.Name = CaseMetadata.CTM_ROLE;
    ctmTeamRole.AccessLevel = 'Edit';

    insert new List<CaseTeamRole>{ csmTeamRole, ctmTeamRole };
  }

  static testMethod void addDefaultTeamMembers_onInsert() {
    Account account = new Account(Name = 'John');
    account.BillingStreet = 'Test Street';
    account.BillingCity = 'Test City';
    account.BillingPostalCode = 'SW1 3DWW';
    account.BillingCountry = 'United Kingdom';
    account.Phone = '1234567890';
    account.Industry = 'Others';
    account.CSM__c = UserInfo.getUserId();
    account.Support_Technical_Advisor__c = UserInfo.getUserId();
    insert account;
    Case incidentCase = new Case();
    incidentCase.RecordTypeId = CaseMetadata.IncidentRecordType;
    incidentCase.Subject = 'Incident  Case';
    incidentCase.Status = 'New';
    incidentCase.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
    incidentCase.No_of_Emails_Sent__c = 1;
    insert incidentCase;
    incidentCase = [SELECT Id, Account_CSM__c, Account_STA__c FROM Case];
    Test.startTest();
    new CaseTeamMemberQueueable(new List<Case>{ incidentCase }).work();
    Test.stopTest();
    System.assertEquals(1, [SELECT Id FROM CaseTeamMember].size(), 'Case Team members is inserted');
  }

  static testMethod void addDefaultTeamMembers_onUpdate() {
    Account account = new Account(Name = 'John');
    account.BillingStreet = 'Test Street';
    account.BillingCity = 'Test City';
    account.BillingPostalCode = 'SW1 3DWW';
    account.BillingCountry = 'United Kingdom';
    account.Phone = '1234567890';
    account.Industry = 'Others';
    account.CSM__c = UserInfo.getUserId();
    account.Support_Technical_Advisor__c = UserInfo.getUserId();
    insert account;
    Case incidentCase = new Case();
    incidentCase.RecordTypeId = CaseMetadata.IncidentRecordType;
    incidentCase.Subject = 'Incident  Case';
    incidentCase.Status = 'New';
    incidentCase.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
    incidentCase.No_of_Emails_Sent__c = 1;
    insert incidentCase;
    incidentCase = [SELECT Id, Account_CSM__c, Account_STA__c FROM Case];

    Test.startTest();
    CaseTeamMemberQueueable.addDefaultTeamMembers(
      new List<Case>{ incidentCase },
      new Map<Id, Case>{ incidentCase.Id => incidentCase }
    );
    Test.stopTest();
    System.assertEquals(1, [SELECT Id FROM CaseTeamMember].size(), 'Case Team members is inserted');
  }
}
