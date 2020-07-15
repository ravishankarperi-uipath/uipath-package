/**
    * @DESCRIPTION: This is Test Class for IntegrationHandler class
    * @AUTHOR: Slalom Consulting
*/
@IsTest
private class IntegrationHandlerTest {

    private static User getAdminUser() {
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
    private static void syncStatusAutomationProcessTest() {

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
        System.runAs(getAdminUser()) {

            IntegrationHandler.syncStatusAutomationProcess(
                new Map<Id, Address__c>{
                    address.Id => address
                },
                new List<Address__c>{
                    updatedAddress
                }
            );
        }

        System.assertEquals(CommonsConstants.ACC_SYNC_STATUS_PENDING, updatedAddress.Sync_Status__c); //Should be Pending

        Test.stopTest();
    }

    @isTest
    private static void updateAccountValidationStatusToReadyForReviewTest() {

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
            new Set<Id>{
                acc.Id
            }
        );

        Account updatedAccount = [SELECT Id, Validation_Status__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(CommonsConstants.ACC_VALIDATION_STATUS_READY_FOR_REVIEW, updatedAccount.Validation_Status__c);

        Address__c updatedAddress = [SELECT Id, Validation_Status__c FROM Address__c WHERE Id = :address.Id];
        System.assertEquals(CommonsConstants.ACC_VALIDATION_STATUS_READY_FOR_REVIEW, updatedAddress.Validation_Status__c);

        Test.stopTest();
    }

    /* Method to test Account update made by data stewards without Boomi integration User Permission Set assigned to them*/
    @isTest
    public static void testAccounttUpdateForDataSteward_WithoutPerSet() {

        Account accRec1 = new Account(
            Name = 'AAAA_testAccounttUpdateForDataSteward_WithoutPerSet1',
            BillingCountryCode = 'US',
            BillingCountry = 'United States',
            BillingState = 'South Dakota',
            BillingStateCode = 'SD',
            Industry = 'Others',
            Legal__c = 'Legal Name',
            Primary_Subsidiary__c = 'UiPath SRL',
            Channel_Tier__c = 'Reseller',
            Validation_Status__c = CommonsConstants.ACC_VALIDATION_STATUS_PENDING,
            Sync_Status__c = CommonsConstants.ACC_SYNC_STATUS_SYNCED);

        Account accRec2 = new Account(
            Name = 'BBBB_testAccounttUpdateForDataSteward_WithoutPerSet',
            BillingCountryCode = 'US',
            BillingCountry = 'United States',
            BillingState = 'South Dakota',
            BillingStateCode = 'SD',
            Industry = 'Others',
            Legal__c = 'Legal Name',
            Primary_Subsidiary__c = 'UiPath SRL',
            Channel_Tier__c = 'Reseller',
            Validation_Status__c = CommonsConstants.ACC_VALIDATION_STATUS_VALIDATED,
            Sync_Status__c = CommonsConstants.ACC_SYNC_STATUS_SYNCED);

        insert accRec1;
        insert accRec2;

        Test.startTest();

        accRec1.Legal__c = 'LegalEntity1';
        accRec2.Legal__c = 'LegalEntity2';

        update new List<Account>{accRec1,accRec2};
        Test.stopTest();
        System.assertEquals(CommonsConstants.ACC_SYNC_STATUS_SYNCED,  [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id =:accRec1.Id].Sync_Status__c, 'Sync Status should NOT be changed to \'Pending\' as Account is NOT Validated and so Sync Automation should not execute for such accounts');
        System.assertEquals(CommonsConstants.ACC_SYNC_STATUS_PENDING,  [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id =:accRec2.Id].Sync_Status__c, 'Sync Status should change to \'Pending\' as Account is Validated and Data Steward has updated the Account field from boomi field set');
    }

    /* Method to test Account update made by data stewards updating the Accounts with Sync Status= Not Valid. It should NOT change the Sync Status and trigger the integration*/
    @isTest
    public static void testAccountUpdateForExcludedSyncStatus_NotValid() {

        Account accRec = new Account(
            Name = 'testAccountUpdateForExcludedSyncStatus_NotValid',
            BillingCountryCode = 'US',
            BillingCountry = 'United States',
            BillingState = 'South Dakota',
            BillingStateCode = 'SD',
            Industry = 'Others',
            Legal__c = 'Legal Name',
            Primary_Subsidiary__c = 'UiPath SRL',
            Channel_Tier__c = 'Reseller');

        insert accRec;

        Test.startTest();
        accRec.Legal__c = 'LegalEntity1';
        update accRec;
        Test.stopTest();

        Account acc = [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id = :accRec.Id];
        System.assertEquals(CommonsConstants.ACC_SYNC_STATUS_NOT_VALID, acc.Sync_Status__c, 'If Sync_Status is set to \'Not Valid\' and any user updates any field from boomi_field_set, status should NOT change');
    }

    /* Method to test Account update made by data stewards updating the Accounts with Sync Status= Do Not Sync. It should NOT change the Sync Status and trigger the integration
    * Also the Account that should be deprecated from syncing to NetSuite will be set as Do Not Sync t*/
    @isTest
    public static void testAccountUpdateForExcludedSyncStatus_DoNotSync() {

        Account accRec = new Account(
            Name = 'testAccountUpdateForExcludedSyncStatus_DoNotSync',
            BillingCountryCode = 'US',
            BillingCountry = 'United States',
            BillingState = 'South Dakota',
            BillingStateCode = 'SD',
            Industry = 'Others',
            Legal__c = 'Legal Name',
            Primary_Subsidiary__c = 'UiPath SRL',
            Channel_Tier__c = 'Reseller');

        accRec.Sync_Status__c = CommonsConstants.ACC_SYNC_STATUS_DO_NOT_SYNC;

        insert accRec;
        Test.startTest();
        accRec.Legal__c = 'LegalEntity1';
        update accRec;
        Test.stopTest();

        Account acc  = [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id = :accRec.Id];
        System.assertEquals(CommonsConstants.ACC_SYNC_STATUS_DO_NOT_SYNC, acc.Sync_Status__c, 'If Sync_Status is set to \'Do Not Sync\' and any user updates any field from boomi_field_set, status should NOT change');
    }

}