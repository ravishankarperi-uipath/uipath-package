/**
 * TODO REWRITE with Mocking as too much DML involved
 */
@isTest
public with sharing class AccountSharingRollupQueueableTest {

    @isTest
    public static void canRunAccountSharingJob() {

        User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        u.Username = 'canRunAccountSharingJob@uipath.com';
        u.LastName = 'Test';
        u.Email = 'canRunAccountSharingJob@uipath.com';
        u.Alias = 't839734';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';

        insert u;

        Account ukAccountParent = new Account(
                Name = 'TestAccountUK',
                Country__c = 'United Kingdom',
                BillingCountry = 'United Kingdom',
                OwnerId = u.Id,
                Industry = 'Others'

        );


        insert ukAccountParent;

        Account ukAccountChild = ukAccountParent.clone();

        ukAccountChild.ParentId = ukAccountParent.Id;
        ukAccountChild.Classification__c = 'Global';
        ukAccountChild.OwnerId=UserInfo.getUserId();

        insert ukAccountChild;

        AccountSharingRollupQueueable accountSharingRollupQueueable = new AccountSharingRollupQueueable(new List<Account>{
                ukAccountChild
        }, null);
        accountSharingRollupQueueable.execute(null);

        List<AccountShare> accountShares = [
                Select Id
                from AccountShare
                where AccountId = :ukAccountChild.Id
                and AccountAccessLevel = 'Edit'
                and OpportunityAccessLevel = 'Edit'
                and UserOrGroupId = :u.Id
        ];
        System.assertEquals(1, accountShares.size());

    }


}
