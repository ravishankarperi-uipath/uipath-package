/**
    * @DESCRIPTION: This is Test Class for AccountTriggerHandler class
    * @AUTHOR: Slalom Consulting
*/

@IsTest
private class AccountTriggerHandlerTest {
    
    @isTest
    public static void testsetUpContactOwner(){

        User u = CreateUser(Constants.SYS_ADMIN_PROFILE,true, true);

        Account ukAccount = new Account(
                Name = 'TestAccountUK',
                Country__c = 'United Kingdom',
                BillingCountry = 'United Kingdom',
                Industry = 'Others');
        
        
        insert ukAccount;
        
        Contact cnt = new Contact(AccountId = ukAccount.Id, LastName = 'TestCnt', LeadSource = 'Event', Email = 'eventcont@testtest123.com');
        insert cnt;

        Account ukAccount1 = [   SELECT Id, OwnerId
                        FROM Account
                        WHERE Id = :ukAccount.Id];
        ukAccount1.OwnerId = u.Id;
        
        Test.startTest();
        update ukAccount1;
        Test.stopTest();
        
        
        Contact cnt1 = [SELECT Id, OwnerId FROM Contact WHERE Id =: cnt.Id LIMIT 1];
        System.assertEquals(u.Id, cnt1.OwnerId);
    }

    @isTest
    public static void setCustomerStageTest(){
        
        // test "New to RPA" customer stage ==================================================
        Account newAccountProve = new Account();
        newAccountProve.Name = 'Account Prove';
        newAccountProve.BillingCountry = 'UNITED STATES';
        newAccountProve.Industry = 'Energy';
        newAccountProve.Overwrite_Classification__c = true; 
        insert newAccountProve;
        
        Account newAccountProve2 = new Account();
        newAccountProve2.Name = 'Account Prove with opp';
        newAccountProve2.BillingCountry = 'UNITED KINGDOM';
        newAccountProve2.Industry = 'Energy';
        newAccountProve2.Overwrite_Classification__c = true;
        insert newAccountProve2;

        Contact newContact = new Contact(
                LastName = 'contRec1',
                AccountId = newAccountProve2.Id,
                Email = 'contRec.Test11@emailDomain.com'
                );
        insert newContact;


        Opportunity newOpportunityProve = new Opportunity();
        newOpportunityProve.Name = 'Opportunity Prove';
        newOpportunityProve.Type = 'New Business';
        newOpportunityProve.Deal_Type__c = 'Direct';
        newOpportunityProve.LeadSource = 'Webinar';
        newOpportunityProve.AccountId = newAccountProve2.Id;
        newOpportunityProve.StageName = 'Discovery';
        newOpportunityProve.CloseDate = (Date.today()).addMonths(-2);
        newOpportunityProve.Discount_Approval_Status__c = 'In Approval';
        newOpportunityProve.Managing_Director__c = UserInfo.getUserId();
        newOpportunityProve.Pricebook2Id = Test.getStandardPricebookId();
        newOpportunityProve.CurrencyIsoCode = 'USD';
        newOpportunityProve.Total_Contact_Roles__c = 1;
        insert newOpportunityProve;
        
        //create contact role
        OpportunityContactRole ocrProve = new OpportunityContactRole();
        ocrProve.OpportunityId = newOpportunityProve.Id;
        ocrProve.ContactId = newContact.Id;
        ocrProve.Role = 'Business User';
        insert ocrProve;
        
        // test "Establish" customer stage ====================================================
        Account newAccountEstablish = new Account();
        newAccountEstablish.Name = 'Account Establish';
        newAccountEstablish.BillingCountry = 'UNITED STATES';
        newAccountEstablish.Industry = 'Energy';
        newAccountEstablish.Overwrite_Classification__c = true;
        insert newAccountEstablish;

        Opportunity newOpportunityEstablish = new Opportunity();
        newOpportunityEstablish.Name = 'Opportunity Establish';
        newOpportunityEstablish.LeadSource = 'Webinar';
        newOpportunityEstablish.Deal_Type__c = 'Direct';
        newOpportunityEstablish.Type = 'New Business';
        newOpportunityEstablish.AccountId = newAccountEstablish.Id;
        newOpportunityEstablish.StageName = 'Discovery';
        newOpportunityEstablish.CloseDate = (Date.today()).addMonths(-2);
        newOpportunityEstablish.Discount_Approval_Status__c = 'In Approval';
        newOpportunityEstablish.Managing_Director__c = UserInfo.getUserId();
        newOpportunityEstablish.Pricebook2Id = Test.getStandardPricebookId();
        newOpportunityEstablish.CurrencyIsoCode = 'USD';
        newOpportunityEstablish.Total_Contact_Roles__c = 1;
        insert newOpportunityEstablish;
        
        //create contact role
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = newOpportunityEstablish.Id;
        ocr.ContactId = newContact.Id;
        ocr.Role = 'Business User';
        insert ocr;

        Product2 productEstablish = new Product2();
        productEstablish.Name = 'UIPath - Attended Robot - test Establish';
        productEstablish.Is_Add_On__c = false;
        productEstablish.IsActive = true;
        productEstablish.Add_On_Percent__c = 10;
        productEstablish.License_Model__c = 'N/A';
        productEstablish.Unit_of_measure__c = 'N/A';
        productEstablish.Family = 'Core Product';
        productEstablish.CPQ_Exclusive__c = true;
        productEstablish.Ext_Id__c='testProductName0220';
        productEstablish.ProductCode='testProductName0220';
        insert productEstablish;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = productEstablish.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 2000;
        pbe.IsActive = true;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
            
        List<OpportunityLineItem> allOLI = new List<OpportunityLineItem>();   
            
        OpportunityLineItem oliEstablish = new OpportunityLineItem();
        oliEstablish.OpportunityId = newOpportunityEstablish.Id;
        oliEstablish.UnitPrice = 700;
        oliEstablish.Quantity = 3;
        oliEstablish.PricebookEntryId = pbe.Id;
        oliEstablish.Discount = 25;
        oliEstablish.Product_Version__c = '2019.4';
        oliEstablish.Add_On_For__c = null;
        oliEstablish.ServiceDate = Date.today().addMonths(-1);
        oliEstablish.End_Date__c = Date.today().addMonths(3);
        oliEstablish.Product2Id = productEstablish.Id;
        allOLI.add(oliEstablish);
        
        // test "Expand to scale" customer stage =============================================
        Account newAccountExpand = new Account();
        newAccountExpand.Name = 'Account Expand';
        newAccountExpand.BillingCountry = 'UNITED STATES';
        newAccountExpand.Industry = 'Energy';
        newAccountExpand.Overwrite_Classification__c = true;
        insert newAccountExpand;

        Opportunity newOpportunityExpand = new Opportunity();
        newOpportunityExpand.Name = 'Opportunity Expand';
        newOpportunityExpand.Type = 'New Business';
        newOpportunityExpand.Deal_Type__c = 'Direct';
        newOpportunityExpand.LeadSource  = 'Webinar';
        newOpportunityExpand.AccountId = newAccountExpand.Id;
        newOpportunityExpand.StageName = 'Discovery';
        newOpportunityExpand.CloseDate = (Date.today()).addMonths(-2);
        newOpportunityExpand.Discount_Approval_Status__c = 'In Approval';
        newOpportunityExpand.Managing_Director__c = UserInfo.getUserId();
        newOpportunityExpand.Pricebook2Id = Test.getStandardPricebookId();
        newOpportunityExpand.CurrencyIsoCode = 'USD';
        newOpportunityExpand.Total_Contact_Roles__c = 1;
        insert newOpportunityExpand;
        
        //create contact role
        OpportunityContactRole ocrExpand = new OpportunityContactRole();
        ocrExpand.OpportunityId = newOpportunityExpand.Id;
        ocrExpand.ContactId = newContact.Id;
        ocrExpand.Role = 'Business User';
        insert ocrExpand;

        Product2 productExpand = new Product2();
        productExpand.Name = 'UIPath - Attended Robot - test Expand';
        productExpand.Is_Add_On__c = false;
        productExpand.IsActive = true;
        productExpand.Add_On_Percent__c = 10;
        productExpand.License_Model__c = 'N/A';
        productExpand.Unit_of_measure__c = 'N/A';
        productExpand.Family = 'Core Product';
        
        productExpand.CPQ_Exclusive__c = true;
        productExpand.Ext_Id__c='testProductName0220';
        productExpand.ProductCode='testProductName0220';
        insert productExpand;
        
        Product2 productExpand2 = new Product2();
        productExpand2.Name = 'UIPath - Unattended Robot - test Expand';
        productExpand2.Is_Add_On__c = false;
        productExpand2.IsActive = true;
        productExpand2.Add_On_Percent__c = 10;
        productExpand2.License_Model__c = 'N/A';
        productExpand2.Unit_of_measure__c = 'N/A';
        productExpand2.Family = 'Core Product';
        productExpand2.CPQ_Exclusive__c = true;
        productExpand2.Ext_Id__c='testProductName0220';
        productExpand2.ProductCode='testProductName0220';
        insert productExpand2;
        
        
        OpportunityLineItem oliExpand = new OpportunityLineItem();
        oliExpand.OpportunityId = newOpportunityExpand.Id;
        oliExpand.UnitPrice = 700;
        oliExpand.Quantity = 10;
        oliExpand.PricebookEntryId = pbe.Id;
        oliExpand.Discount = 25;
        oliExpand.Product_Version__c = '2019.4';
        oliExpand.Add_On_For__c = null;
        oliExpand.ServiceDate = Date.today().addMonths(-1);
        oliExpand.End_Date__c = Date.today().addMonths(3);
        oliExpand.Product2Id = productExpand.Id;
        allOLI.add(oliExpand);
        
        OpportunityLineItem oliExpand2 = new OpportunityLineItem();
        oliExpand2.OpportunityId = newOpportunityExpand.Id;
        oliExpand2.UnitPrice = 400;
        oliExpand2.Quantity = 5;
        oliExpand2.PricebookEntryId = pbe.Id;
        oliExpand2.Discount = 25;
        oliExpand2.Product_Version__c = '2019.4';
        oliExpand2.Add_On_For__c = null;
        oliExpand2.ServiceDate = Date.today().addMonths(-1);
        oliExpand2.End_Date__c = Date.today().addMonths(3);
        oliExpand2.Product2Id = productExpand2 .Id;
        allOLI.add(oliExpand2);
        
        insert allOLI;
      
        // update opps ======================================================================================
        
        List<Opportunity> updateOpp1 = new List<Opportunity>();
        List<Opportunity> updateOpp = [SELECT Id, CloseDate, StageName  FROM Opportunity ];
        for(Opportunity o: updateOpp){
            if(o.Id != newOpportunityProve.Id) {
                Date d = Date.today();
                o.StageName = 'Closed Won Booked';
                o.Contract_Start_Date__c = (Date.Today()).addMonths(-1);
                o.Contract_End_Date__c = (Date.Today()).addMonths(9);
                o.Competition__c = 'Blue Prism';
                o.Reason_1__c = 'Technical features';
                o.Reason_2__c = 'CoE enablement strategy';
                o.Reason_3__c = 'Product roadmap';
                o.Closeout_Reason__c ='test123 test123 test123 test123';
                o.Features_the_customer_liked_didn_t_like__c ='test99 test123 test123 test99';
                o.Product_Renewal_Date__c = d.addYears(1);
                o.FinanceReviewReached__c = true;            
                updateOpp1.add(o);
            }
        }
        
        update updateOpp1;
        
        
        Test.startTest();
            List<Account> allAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Account%'];
            update allAccounts;
            List<Account> Accounts = [SELECT Id, Name, Customer_Stage__c FROM Account WHERE Name LIKE 'Account%'];
        Test.stopTest();

        for(Account acc: Accounts)
        {
            if(acc.Name == 'Account Prove' || acc.Name == 'Account Prove with opp')
                System.assertEquals('Prove', acc.Customer_Stage__c);
            if(acc.Name == 'Account Establish')
                System.assertEquals('Establish', acc.Customer_Stage__c);
            if(acc.Name == 'Account Expand')
                System.assertEquals('Expand', acc.Customer_Stage__c);    
        }
        
    }
    

    
    /* Test data preparation */
    private static List<Account> CreateAccounts(Integer noOfAccounts){

        List<Account> accToInsertLst = new List<Account>();

        for(Integer i=0;i<noOfAccounts;i++){
            // To avoid the salesforce duplication detection it is necessary to create Accounts with unique names, hence the below logic
            String testAccName = 'TestAlphaAccountBetaAccounttesting';
            String uniqueName = testAccName.substring(i)+(i+1*3)+testAccName.charAt(i)+testAccName.left(2)+(i*2);

            Account accRec = new Account(
                    Name = uniqueName,
                    BillingCountryCode = 'US',
                    BillingCountry = 'United States',
                    BillingState = 'South Dakota',
                    BillingStateCode = 'SD',
                    Industry = 'Others',
                    Legal__c = 'Legal Name',
                    DNBoptimizer__DNB_D_U_N_S_Number__c = '1234567',
                    Default_Payment_Terms__c = '30 Days Net',
                    Primary_Subsidiary__c = 'UiPath SRL',
                    Channel_Tier__c = 'Reseller');
            accToInsertLst.add(accRec);
        }
        return accToInsertLst;
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
                PermissionSet permSet = [SELECT Id from PermissionSet where name = :Constants.BOOMI_INTEGRATION_PERMISSION_SET_NAME limit 1];
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = permSet.Id;
                insert psa;
            }
        }

        return u;
    }

    /* Method to test default values are set for Sync Status and Validation Status on new Account creation*/
    @isTest
    static void testCreateAccount() {
        List<Account> accLst =  CreateAccounts(10);

        Test.startTest();
        List<Database.SaveResult> insertResultLst = Database.insert(accLst,false);
        Test.stopTest();

        //Verify Results
        list<Account> accListNew = [select id, Geo__c, Region__c, Area__c,Sync_Status__c,Validation_Status__c from Account where id in :accLst];

        System.assertEquals('NorthWest',accListNew.get(0).Region__c);
        System.assertEquals(Constants.ACC_SYNC_STATUS_NOT_VALID,accListNew.get(0).Sync_Status__c,'By default the Sync Status is set to \'Not Valid\' on new Account');
        System.assertEquals(Constants.ACC_VALIDATION_STATUS_PENDING,accListNew.get(0).Validation_Status__c,'By default the Validation Status is set to \'Pending\' on new Account');
    }

    /* Method to test the Sync Status change when Account Validation Status is set to Validated*/
    @isTest
    static void testSetSyncStatusForValidatedAccount() {

        User u = CreateUser(Constants.INTEGRATION_USER_PROFILE,true, true);

        List<Account> accLst = CreateAccounts(20);

        Test.startTest();

        System.runAs(u) {
            insert accLst;


            Account accObj1 = accLst.get( 0 );
            accObj1.Validation_Status__c = Constants.ACC_VALIDATION_STATUS_VALIDATED;

            accObj1.Legal__c = 'Legal Name';
            accObj1.DNBoptimizer__DNB_D_U_N_S_Number__c = 'DNS123';
            accObj1.Default_Payment_Terms__c = '30 Days Net';
            accObj1.Primary_Subsidiary__c = 'UiPath SRL';
            accObj1.Channel_Tier__c = 'Reseller';
            accObj1.Industry = 'Retail';

            Account accObj2 = accLst.get( 1 );
            accObj2.Validation_Status__c = Constants.ACC_VALIDATION_STATUS_VALIDATED;
            accObj2.Legal__c = 'Legal Name';
            accObj2.DNBoptimizer__DNB_D_U_N_S_Number__c = 'DNS123';
            accObj2.Default_Payment_Terms__c = '30 Days Net';
            accObj2.Primary_Subsidiary__c = 'UiPath SRL';
            accObj2.Channel_Tier__c = 'Reseller';
            accObj2.Industry = 'Retail';


            accLst = new List<Account>();
            accLst.add( accObj1 );
            accLst.add( accObj2 );

            Update accLst;
        }

        Test.stopTest();

        //Verify Results
        list<Account> accListNew = [select id, Sync_Status__c,Validation_Status__c from Account where id in :accLst];

        System.assertEquals(Constants.ACC_SYNC_STATUS_VALID,accListNew.get(0).Sync_Status__c,'if Validation Status is set to Validated, then Sync Status should be set to Valid');
        System.assertEquals(Constants.ACC_SYNC_STATUS_VALID,accListNew.get(1).Sync_Status__c,'if Validation Status is set to Validated, then Sync Status should be set to Valid');
    }

    /* Method to test Account update made bu integration user*/
    @isTest
    public static void testAccountUpdateForIntegrationUser(){

        User u = CreateUser(Constants.INTEGRATION_USER_PROFILE,true, true);
        List<Account> accLst = CreateAccounts(20);

        //Set the Account Sync Status to "Synced"
        for(Account accObj: accLst){
            accObj.Sync_Status__c=Constants.ACC_SYNC_STATUS_SYNCED;
        }
        insert accLst;

        Test.startTest();

        System.runAs(u) {
            for(Integer i=0;i<accLst.size();i++){
                accLst.get(i).Legal__c= 'LegalEntity'+(i*20);
            }

            update accLst;
        }
        Test.stopTest();

        List<Account> accResultLst = [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id in :accLst];
        System.assertEquals(Constants.ACC_SYNC_STATUS_SYNCED, accResultLst.get(0).Sync_Status__c, 'Status should not have changed as updates made by integration user should not change the Sync Status');
    }

    /* Method to test Account update made by data stewards with Boomi integration User Permission Set assigned to them*/
    @isTest
    public static void testAccountUpdateForDataSteward_WithPerSet(){

        User u = CreateUser(Constants.DATA_STEWARD_PROFILE,true, true);
        List<Account> accLst = CreateAccounts(20);

        //Set the Account Sync Status to "Synced"
        for(Account accObj: accLst){
            accObj.Sync_Status__c=Constants.ACC_SYNC_STATUS_SYNCED;
        }
        insert accLst;

        Test.startTest();

        System.runAs(u) {
            for(Integer i=0;i<accLst.size();i++){
                accLst.get(i).Legal__c= 'LegalEntity'+(i*20);
            }

            update accLst;
        }
        Test.stopTest();

        List<Account> accResultLst = [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id in :accLst];
        System.assertEquals(Constants.ACC_SYNC_STATUS_SYNCED, accResultLst.get(0).Sync_Status__c, 'Status should not have changed as user with Boomi Integration Permission Set should not be changing the sync status');
    }

    /* Method to test Account update made by data stewards without Boomi integration User Permission Set assigned to them*/
    @isTest
    public static void testAccounttUpdateForDataSteward_WithoutPerSet(){

        User u = CreateUser(Constants.DATA_STEWARD_PROFILE,false, true);
        List<Account> accLst = CreateAccounts(20);

        //For 0-9 Accounts, set the Account Validation Status to "Pending" and "Sync Status" to "Synced"
        for(Integer i=0;i<=9; i++){
            accLst.get(i).Validation_Status__c=Constants.ACC_VALIDATION_STATUS_PENDING;
            accLst.get(i).Sync_Status__c=Constants.ACC_SYNC_STATUS_SYNCED;
        }

        //For 10-19 Accounts, set the Account Validation Status to "Validated" and "Sync Status" to "Synced"
        for(Integer i=10;i<=19; i++){
            accLst.get(i).Validation_Status__c=Constants.ACC_VALIDATION_STATUS_VALIDATED;
            accLst.get(i).Sync_Status__c=Constants.ACC_SYNC_STATUS_SYNCED;
        }
        insert accLst;

        Test.startTest();

        System.runAs(u) {
            for(Integer i=0;i<accLst.size();i++){
                accLst.get(i).Legal__c= 'LegalEntity'+(i*20);
            }

            update accLst;
        }
        Test.stopTest();

        List<Account> accResultLst = [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id in :accLst];
        System.assertEquals(Constants.ACC_SYNC_STATUS_SYNCED, accResultLst.get(0).Sync_Status__c, 'Sync Status should NOT be changed to \'Pending\' as Account is NOT Validated and so Sync Automation should not execute for such accounts');
        System.assertEquals(Constants.ACC_SYNC_STATUS_SYNCED, accResultLst.get(9).Sync_Status__c, 'Sync Status should NOT be changed to \'Pending\' as Account is NOT Validated and so Sync Automation should not execute for such accounts');
        System.assertEquals(Constants.ACC_SYNC_STATUS_PENDING, accResultLst.get(10).Sync_Status__c, 'Sync Status should change to \'Pending\' as Account is Validated and Data Steward has updated the Account field from boomi field set');
        System.assertEquals(Constants.ACC_SYNC_STATUS_PENDING, accResultLst.get(19).Sync_Status__c, 'Sync Status should change to \'Pending\' as Account is Validated and Data Steward has updated the Account field from boomi field set');
    }

    /* Method to test Account update made by data stewards updating the Accounts with Sync Status= Not Valid. It should NOT change the Sync Status and trigger the integration*/
    @isTest
    public static void testAccountUpdateForExcludedSyncStatus_NotValid(){

        User u = CreateUser(Constants.DATA_STEWARD_PROFILE,false, true);
        List<Account> accLst = CreateAccounts(20);

        insert accLst;

        Test.startTest();

        System.runAs(u) {
            for(Integer i=0;i<accLst.size();i++){
                accLst.get(i).Legal__c= 'LegalEntity'+(i*20);
            }

            update accLst;
        }
        Test.stopTest();

        List<Account> accResultLst = [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id in :accLst];
        System.assertEquals(Constants.ACC_SYNC_STATUS_NOT_VALID, accResultLst.get(0).Sync_Status__c, 'If Sync_Status is set to \'Not Valid\' and any user updates any field from boomi_field_set, status should NOT change');
    }

    /* Method to test Account update made by data stewards updating the Accounts with Sync Status= Do Not Sync. It should NOT change the Sync Status and trigger the integration
    * Also the Account that should be deprecated from syncing to NetSuite will be set as Do Not Sync t*/
    @isTest
    public static void testAccountUpdateForExcludedSyncStatus_DoNotSync(){

        User u = CreateUser(Constants.DATA_STEWARD_PROFILE,false, true);
        List<Account> accLst = CreateAccounts(20);

        //Set the Account Sync Status to "Do Not Sync"
        for(Account accObj: accLst){
            accObj.Sync_Status__c=Constants.ACC_SYNC_STATUS_DO_NOT_SYNC;
        }
        insert accLst;

        Test.startTest();

        System.runAs(u) {
            for(Integer i=0;i<accLst.size();i++){
                accLst.get(i).Legal__c= 'LegalEntity'+(i*80);
            }

            update accLst;
        }
        Test.stopTest();

        List<Account> accResultLst = [SELECT Id, Name, Sync_Status__c FROM Account WHERE Id in :accLst];
        System.assertEquals(Constants.ACC_SYNC_STATUS_DO_NOT_SYNC, accResultLst.get(0).Sync_Status__c, 'If Sync_Status is set to \'Do Not Sync\' and any user updates any field from boomi_field_set, status should NOT change');
    }

    /* This is the method from the AccountTriggerTest Class written bu UiPath. Moved here as we should maintain only one AccountTriggerHandler class and its test class*/
    @isTest
    public static void testSetRegionOnAccount()
    {
        //setup data
        list<Account> accList = new list<Account>();

        Account a0 = new Account(
                Name = 'TestAcc349640',
                BillingCountryCode = 'US',
                Industry = 'Insurance');

        accList.add(a0);

        Account a1 = new Account(
                Name = 'TestAcc349641',
                BillingCountryCode = 'US',
                BillingState = 'South Dakota',
                BillingStateCode = 'SD',
                Industry = 'Others');

        accList.add(a1);

        Account a2 = new Account(
                Name = 'TestAcc349642',
                BillingCountryCode = 'US',
                BillingPostalCode = '15001',
                Industry = 'Others');

        accList.add(a2);

        Account a3 = new Account(
                Name = 'TestAcc349643',
                BillingCountryCode = 'US',
                Industry = 'Others');

        accList.add(a3);

        Account a4 = new Account(
                Name = 'TestAcc349644',
                BillingCountryCode = 'PK',
                Industry = 'Others');

        accList.add(a4);

        Account a5 = new Account(
                Name = 'TestAcc349645',
                BillingCountryCode = 'PK',
                Industry = 'Others');

        accList.add(a5);

        Account a6 = new Account(
                Name = 'TestAcc349646',
                BillingCountryCode = 'US',
                Industry = 'Insurance');

        accList.add(a6);

        //do the tests
        test.startTest();


        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList = Database.insert(accList, dml);


        account aTmp = [select id, BillingCountryCode from Account where id = :a5.Id];

        // For some reason, in production, there is a duplicate check that fails here
        //aTmp.BillingCountryCode = 'US';
        //aTmp.Industry = 'Insurance';
        //update aTmp;

        test.stopTest();

        //verify the results
        list<Account> accListNew = [select id, Geo__c, Region__c, Area__c from Account where id in :accList];
        map<Id, Account> accMapNew = new map<Id, Account>(accListNew);

        System.assertEquals(7, accListNew.size());
        System.assertEquals('AMER',accMapNew.get(a0.Id).Geo__c);
        System.assertEquals('NorthWest', accMapNew.get(a1.Id).Region__c);
        System.assertEquals('NorthCentral', accMapNew.get(a2.Id).Region__c);
        System.assertEquals(null, accMapNew.get(a3.Id).Region__c);
        System.assertEquals('EMEA', accMapNew.get(a4.Id).Geo__c);
        System.assertEquals('EMEA', accMapNew.get(a5.Id).Geo__c);
        System.assertEquals('AMER North & BFS', accMapNew.get(a6.Id).Area__c);
    }



    /* Method to test Account insert and to check the subsidiary is being set*/
    @isTest
    public static void testAccountSubsidiary(){

        User u = CreateUser(Constants.SYS_ADMIN_PROFILE,true, true);

        Account ukAccount = new Account(
                Name = 'TestAccountUK',
                Country__c = 'United Kingdom',
                BillingCountry = 'United Kingdom',
                Industry = 'Others');

        Test.startTest();

        System.runAs(u) {
            insert ukAccount;
        }
        Test.stopTest();

        ukAccount = [   SELECT Id, Name, Country__c, BillingCountry, Industry, Primary_Subsidiary__c
                        FROM Account
                        WHERE Id = :ukAccount.Id];
        System.assertEquals('UiPath SRL',ukAccount.Primary_Subsidiary__c);
    }


    /* Method to test Account insert through D&B and check address is handled correctly*/
    @isTest
    public static void testCreateAccountFromDNBHoovers(){

        User u = CreateUser(Constants.SYS_ADMIN_PROFILE,true, true);

        //Set street > 150 characters to test 2nd street line
        Account ukAccount = new Account(
                Name = 'TestAccountUK',
                DnB_Country__c = 'United Kingdom',
                DnB_Street__c = '01234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789',
                DnB_City__c = 'London',
                DnB_Zip_Postal_Code__c = 'W12 345',
                Industry = 'Others');

        Test.startTest();

        System.runAs(u) {
            insert ukAccount;
        }
        Test.stopTest();

        ukAccount = [   SELECT Id, Name, Country__c, BillingCountry, Industry
                        FROM Account
                        WHERE Id = :ukAccount.Id];
        System.assertEquals('United Kingdom',ukAccount.Country__c);
        System.assertEquals('United Kingdom',ukAccount.BillingCountry);

        List<Address__c> addressList = [SELECT Id, Account__c, Primary_Billing__c, Primary_Shipping__c, D_B_Address__c, Country__c, Street_Line_1__c, Street_Line_2__c, City__c,  Zip_Postal_Code__c
                                        FROM Address__c
                                        WHERE Account__c =: ukAccount.Id];
        System.assertEquals(1,addressList.size());
        System.assertEquals('United Kingdom',addressList[0].Country__c);
        System.assert( String.IsNotBlank( addressList[0].Street_Line_1__c ));
        System.assert(addressList[0].D_B_Address__c);
        System.assert(addressList[0].Primary_Billing__c);
    }


    /* Method to test Account insert through lead conversion and check address is handled correctly*/
    @isTest
    public static void testCreateAccountThroughLeadConversion(){

        User u = CreateUser(Constants.SYS_ADMIN_PROFILE,true, true);

        //Set street > 150 characters to test 2nd street line
        Account ukAccount = new Account(
                Name = 'TestAccountUK',
                BillingCountry = 'United Kingdom',
                BillingStreet = '01234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789',
                BillingCity = 'London',
                BillingPostalCode = 'W12 345',
                Industry = 'Others');

        Test.startTest();

        System.runAs(u) {
            insert ukAccount;
        }
        Test.stopTest();

        ukAccount = [   SELECT Id, Name, Country__c, BillingCountry, Industry
                        FROM Account
                        WHERE Id = :ukAccount.Id];
        System.assertEquals('United Kingdom',ukAccount.Country__c);

        List<Address__c> addressList = [SELECT Id, Account__c, Primary_Billing__c, Primary_Shipping__c, Country__c, Street_Line_1__c, Street_Line_2__c, City__c,  Zip_Postal_Code__c
                                        FROM Address__c
                                        WHERE Account__c =: ukAccount.Id];
        System.assertEquals(1,addressList.size());
        System.assertEquals('United Kingdom',addressList[0].Country__c);
        System.assert( String.IsNotBlank( addressList[0].Street_Line_1__c ));
        System.assert(addressList[0].Primary_Billing__c);
    }


    /* Method to test Account address creation on DnB account matching*/
    @isTest
    public static void testAccountDNBAddress(){
        User u = CreateUser(Constants.SYS_ADMIN_PROFILE,true, true);

        //Set street > 150 characters to test 2nd street line
        Account ukAccount = new Account(
                Name = 'TestAccountUK',
                Country__c = 'United Kingdom',
                Industry = 'Others');

        insert ukAccount;

        ukAccount.DnB_Country__c = 'United Kingdom';
        ukAccount.DnB_Street__c = '01234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789012345567890123455678901234556789';
        ukAccount.DnB_City__c = 'London';
        ukAccount.DnB_Zip_Postal_Code__c = 'W44 444';


        Test.startTest();

        System.runAs(u) {
            update ukAccount;
        }
        Test.stopTest();

        ukAccount = [   SELECT Id, Name, Country__c, BillingCountry, BillingPostalCode, Industry
                        FROM Account
                        WHERE Id = :ukAccount.Id];
        System.assertEquals('W44 444',ukAccount.BillingPostalCode);

        List<Address__c> addressList = [SELECT Id, Account__c, Primary_Billing__c, Primary_Shipping__c, Country__c, Street_Line_1__c, Street_Line_2__c, City__c,  Zip_Postal_Code__c
                                        FROM Address__c
                                        WHERE Account__c =: ukAccount.Id];
        System.assertEquals(2,addressList.size());

        addressList = [SELECT Id, Account__c, Primary_Billing__c, Primary_Shipping__c, Country__c, Street_Line_1__c, Street_Line_2__c, City__c,  Zip_Postal_Code__c
                        FROM Address__c
                        WHERE Account__c =: ukAccount.Id AND
                            Zip_Postal_Code__c = 'W44 444'];
        System.assertEquals(1,addressList.size());
        System.assert(addressList[0].Primary_Billing__c);
        System.assert(addressList[0].Primary_Shipping__c);

        //check that address that was created on account creation no longer is marked as primary
        addressList = [SELECT Id, Account__c, Primary_Billing__c, Primary_Shipping__c, Country__c, Street_Line_1__c, Street_Line_2__c, City__c,  Zip_Postal_Code__c
                        FROM Address__c
                        WHERE Account__c =: ukAccount.Id AND
                                Zip_Postal_Code__c = ''];
        System.assert(!addressList[0].Primary_Billing__c);
        System.assert(!addressList[0].Primary_Shipping__c);
    }


}