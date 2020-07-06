@isTest
private class AccountUpdateJapanContactQueueableTest {
    
    @isTest
    private static void setLeadSourceOnContactTest(){
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Country = 'Japan',
            Industry = 'Automotive'
        );
        insert lead;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.convertLead(lc);

        Account acc = [SELECT Id, Country__c, Created_by_lead_convert__c FROM Account WHERE Name = 'Test Company'];

        // TODO : remove it after moving it to Contact before Trigger as currently it's depend on org Lead Mapping
        acc.Created_by_lead_convert__c = true;
        acc.Country__c = 'Japan';
        
        AccountUpdateJapanContactQueueable accountUpdateJapanContactQueueable = new AccountUpdateJapanContactQueueable(
            new List<Account>{ acc }
        );
        accountUpdateJapanContactQueueable.execute(null);

        Contact con = [SELECT Id, LeadSource FROM Contact WHERE AccountId = :acc.Id];
        System.assertEquals('Partner', con.LeadSource);
    }
}
