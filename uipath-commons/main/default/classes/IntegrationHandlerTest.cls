/**
    * @DESCRIPTION: This is Test Class for IntegrationHandler class
    * @AUTHOR: Slalom Consulting
*/
@IsTest
private class IntegrationHandlerTest {

    private static User getAdminUser(){
        User adminUser = new User();
        adminUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        adminUser.Username = 'test839734@uiath.com';
        adminUser.LastName = 'Test';
        adminUser.Email = 'test839734@uiath.com';
        adminUser.Alias = 't839734';
        adminUser.TimeZoneSidKey = 'America/Los_Angeles';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        insert adminUser;

        return adminUser;
    }

    @isTest
    private static void syncStatusAutomationProcessTest(){
        
        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'syncStatusAutomationProcessTest',
            Country__c = 'United Kingdom'
        );

        Address__c address = new Address__c(
            Id = fflib_IDGenerator.generate(Address__c.SObjectType),
            Account__c = acc.Id,
            Primary_Billing__c = true,
            Primary_Shipping__c = true,
            Created_From_Account__c = true,
            Country__c = 'United Kingdom',
            Sync_Status__c = 'Synced'
        );
        
        Address__c updatedAddress = new Address__c(
            Id = address.Id,
            Account__c = acc.Id,
            Primary_Billing__c = true,
            Primary_Shipping__c = true,
            Created_From_Account__c = true,
            Country__c = 'United Kingdom',
            City__c = 'London',
            Sync_Status__c = 'Synced'
        );

        Test.startTest();
            System.runAs(getAdminUser()){

                IntegrationHandler.syncStatusAutomationProcess(
                    new Map<Id, Address__c>{address.Id => address},
                    new List<Address__c>{updatedAddress}
                );
            }

            System.assertEquals(CommonsConstants.ACC_SYNC_STATUS_PENDING, updatedAddress.Sync_Status__c); //Should be Pending

        Test.stopTest();
    }

    @isTest
    private static void updateAccountValidationStatusToReadyForReviewTest(){
        
        Account acc = new Account(
            Name = 'Test Acc',
            BillingCountry = 'United Kingdom',
            Country__c = 'United Kingdom',
            Industry = 'Others',
            Validation_Status__c = CommonsConstants.ACC_SYNC_STATUS_PENDING
        );
        insert acc;

        Address__c address = new Address__c(
            Account__c = acc.Id,
            Primary_Billing__c = true,
            Primary_Shipping__c = true,
            Created_From_Account__c = true,
            Country__c = 'United Kingdom',
            Validation_Status__c = CommonsConstants.ACC_SYNC_STATUS_PENDING
        );
        insert address;

        Test.startTest();
            
        IntegrationHandler.updateAccountValidationStatusToReadyForReview(
            new Set<Id>{acc.Id}
        );
        
        Account updatedAccount = [SELECT Id, Validation_Status__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(CommonsConstants.ACC_VALIDATION_STATUS_READY_FOR_REVIEW, updatedAccount.Validation_Status__c);

        Address__c updatedAddress = [SELECT Id, Validation_Status__c FROM Address__c WHERE Id = :address.Id];
        System.assertEquals(CommonsConstants.ACC_VALIDATION_STATUS_READY_FOR_REVIEW, updatedAddress.Validation_Status__c);

        Test.stopTest();
    }
}