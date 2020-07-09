/**
    * @DESCRIPTION: This is Test Class for IntegrationHandler class
    * @AUTHOR: Slalom Consulting
*/
@IsTest
private class IntegrationHandlerTest {

    private static Product2 CreateProduct(String syncStatus, Boolean insertProduct){

        Product2 product = new Product2(
                Name = 'Test product ',
                ProductCode = 'testProductName',
                Family = 'Core Product',
                Sync_Status__c = syncStatus,
                Ext_Id__c = 'testProductName600'
        );

        if(insertProduct) {
            insert product;
        }
        return product;
    }

    private static User CreateUser(String profileName, Boolean assignIntegrationPermSet, Boolean insertUser){

        User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        u.Username = 'test839734@uiath.com';
        u.LastName = 'Test';
        u.Email = 'test839734@uiath.com';
        u.Alias = 't839734';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';

        if(insertUser) {
            insert u;
        }

        if(assignIntegrationPermSet){
            System.runAs(new User(Id = Userinfo.getUserId())) {
                PermissionSet permSet = [SELECT Id from PermissionSet where name = :CommonsConstants.BOOMI_INTEGRATION_PERMISSION_SET_NAME limit 1];
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = permSet.Id;
                insert psa;
            }
        }

        return u;
    }

    @isTest
    public static void testProductUpdateForIntegrationUser(){

        User u = CreateUser('Integration User',true, true);
        Product2 product = CreateProduct('Synced', true);

        Test.startTest();

        System.runAs(u) {
            product.Name = 'Product';
            update product;
        }
        Test.stopTest();

        Product2 result = [SELECT Id, Name, Sync_Status__c FROM Product2 WHERE Id=:product.Id LIMIT 1];
        System.assertEquals('Synced', result.Sync_Status__c, 'Status should not have changed as Integration user should not be changing the status');
    }


    @isTest
    public static void testProductUpdateForStandardUser_WithPerSet(){

        User u = CreateUser('Standard User',true, true);
        Product2 product = CreateProduct('Synced', true);

        Test.startTest();

        System.runAs(u) {
            product.Name = 'Product';
            update product;
        }
        Test.stopTest();

        Product2 result = [SELECT Id, Name, Sync_Status__c FROM Product2 WHERE Id=:product.Id LIMIT 1];
        System.assertEquals('Synced', result.Sync_Status__c, 'Status should not have changed as the Standard User with Boomi Integration Permission Set should not be changing the sync status');
    }

    @isTest
    public static void testProductUpdateForStandardUser_WithoutPerSet(){

        Product2 product = CreateProduct('Synced', true);
        User u = CreateUser('Standard User',false, true);

        Test.startTest();

        System.runAs(u) {
            product.Name = 'Product';
            update product;
        }
        Test.stopTest();

        Product2 result = [SELECT Id, Name, Sync_Status__c FROM Product2 WHERE Id=:product.Id LIMIT 1];
        System.assertEquals('Pending', result.Sync_Status__c,'Sync Status should change to \'Pending\' as Standard user has updated the field from boomi field set');
    }

    @isTest
    public static void testProductUpdateForExcludedSyncStatus_NotValid(){

        Product2 product = CreateProduct('Not Valid', true);
        User u = CreateUser('Standard User',false, true);

        Test.startTest();

        System.runAs(u) {
            product.Name = 'Product';
            update product;
        }
        Test.stopTest();

        Product2 result = [SELECT Id, Name, Sync_Status__c FROM Product2 WHERE Id=:product.Id LIMIT 1];
        System.assertEquals('Not Valid', result.Sync_Status__c, 'If Sync_Status is set to \'Not Valid\' and user updates any field from boomi_field_set, status should NOT change');
    }

    @isTest
    public static void testProductUpdateForExcludedSyncStatus_DoNotSync(){

        Product2 product = CreateProduct('Do Not Sync', true);
        User u = CreateUser('Standard User',false, true);

        Test.startTest();

        System.runAs(u) {
            product.Name = 'Product';
            update product;
        }
        Test.stopTest();

        Product2 result = [SELECT Id, Name, Sync_Status__c FROM Product2 WHERE Id=:product.Id LIMIT 1];
        System.assertEquals('Do Not Sync', result.Sync_Status__c, 'If Sync_Status is set to \'Do Not Sync\' and user updates any field from boomi_field_set, status should NOT change');
    }


    @isTest
    public static void testAccounts()
    {
        List<Account> accounts = createNewAccount('test name', 5);

        insert accounts;

        List<Address__c> addresses = new List<Address__c>();
        for(Account a :accounts){
            addresses.addAll(createAddress(5, a.id));
        }

        insert addresses;

        Set<Id> accountIds = (new Map<Id,SObject>(accounts)).keySet();
        IntegrationHandler.updateAccountValidationStatusToReadyForReview(accountIds);

        for(Account acct :[SELECT id, Validation_Status__c, (SELECT id, Validation_Status__c FROM Addresses__r) FROM Account WHERE Id  in :accountIds]) {

            System.assertEquals(CommonsConstants.ACC_VALIDATION_STATUS_READY_FOR_REVIEW, acct.Validation_Status__c, 'Opportunity stage has changed to configured value, so the validation status of the account should be ready for review.');
            for (Address__c a : acct.Addresses__r) {
                System.assertEquals(CommonsConstants.ACC_VALIDATION_STATUS_READY_FOR_REVIEW, a.Validation_Status__c, 'Opportunity stage has changed to configured value, so the validation status of the address should be ready for review.');
            }
        }
    }

    private static List<Account> createNewAccount(string name, integer numberOfRecords) {

        List<Account> accounts = new List<Account>();

        for(integer i =0; i<numberOfRecords; i++) {
            Account newAccount = new Account();

            newAccount.Name = name + i;
            newAccount.BillingCountry = 'United Kingdom';
            newAccount.Industry = 'Energy';
            newAccount.Validation_Status__c = 'Pending';

            accounts.add(newAccount);
        }

        return accounts;
    }

    private static List<Address__c> createAddress(integer numberOfRecords, id accountId) {

        List<Address__c> addresses = new List<Address__c>();

        for(integer i =0; i<numberOfRecords; i++){
            Address__c addObj = new Address__c(
                    Street_Line_1__c = 'Test Street Line 1'+i,
                    Street_Line_2__c = 'Test Street Line 2'+i,
                    City__c = 'London',
                    State__c = 'England',
                    Country__c = 'United Kingdom',
                    Zip_Postal_Code__c = '416778',
                    Account__c = accountId,
                    Validation_Status__c = 'Pending' );

            addresses.add(addObj);
        }

        return addresses;
    }
}