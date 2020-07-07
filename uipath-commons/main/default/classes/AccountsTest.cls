@IsTest
public class AccountsTest {
    @IsTest
    private static void validatesStateRequiredForChinaAustralia() {
        Accounts accounts = new Accounts(
            new List<Account>{
                new Account(Name = 'Test', Country__c = 'China', State__c = null)
            }
        );
        accounts.onValidate();
        System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());
        System.assertEquals(
            'State is required if Country is China',
            fflib_SObjectDomain.Errors.getAll()[0].message
        );
        System.assertEquals(
            Account.State__c,
            ((fflib_SObjectDomain.FieldError) fflib_SObjectDomain.Errors.getAll()[0])
                .field
        );
    }

    @IsTest
    private static void copiesStateToBillingStateIfCountryNotChinaAustralia() {
        Account account = new Account(
            Name = 'Test',
            Country__c = 'India',
            State__c = 'Gujarat'
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<Account>{
            account
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('Gujarat', account.BillingState);
    }

    @IsTest
    private static void copiesCountryToBillingCountryOnlyIfNotAlreadySet() {
        Account accountA = new Account(
            Name = 'Test',
            Country__c = 'India',
            State__c = 'Gujarat'
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<Account>{
            accountA
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('India', accountA.BillingCountry);

        // If already set, leave it as it is
        Account accountB = new Account(
            Name = 'Test',
            Country__c = 'India',
            State__c = 'Gujarat',
            BillingCountry = 'United Kingdom'
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<Account>{
            accountB
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('United Kingdom', accountB.BillingCountry);
    }

    @IsTest
    private static void derivesCountryFromCountryCodeOnlyIfNotAlreadySet() {
        Account accountA = new Account(Name = 'Test', BillingCountryCode = 'IN');
        fflib_SObjectDomain.Test.Database.onInsert(new List<Account>{
            accountA
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('India', accountA.BillingCountry);

        // If already set, leave it as it is
        Account accountB = new Account(
            Name = 'Test',
            BillingCountryCode = 'IN',
            BillingCountry = 'United Kingdom'
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<Account>{
            accountB
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('United Kingdom', accountB.BillingCountry);
    }

    @IsTest
    private static void copiesAddressFromDnB() {
        Account accountA = new Account(
            Name = 'Test',
            DnB_Country__c = 'United Kingdom',
            DnB_Street__c = '21 Maple Mews',
            DnB_City__c = 'London',
            DnB_Zip_Postal_Code__c = 'SW16 2AL',
            DnB_State_Province__c = 'Surrey'
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<Account>{
            accountA
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);

        System.assertEquals('United Kingdom', accountA.Country__c);
        System.assertEquals('United Kingdom', accountA.BillingCountry);
        System.assertEquals('21 Maple Mews', accountA.BillingStreet);
        System.assertEquals('London', accountA.BillingCity);
        System.assertEquals('SW16 2AL', accountA.BillingPostalCode);
        System.assertEquals('Surrey', accountA.BillingState);

        //Copies billing address into shipping address on insert
        System.assertEquals('United Kingdom', accountA.ShippingCountry);
        System.assertEquals('21 Maple Mews', accountA.ShippingStreet);
        System.assertEquals('London', accountA.ShippingCity);
        System.assertEquals('SW16 2AL', accountA.ShippingPostalCode);
        System.assertEquals('Surrey', accountA.ShippingState);
    }

    @IsTest
    private static void cannotSelectDandBCompanyFromDifferentCountry() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account oldAccount = new Account(
            Id = accountId,
            Name = 'Test',
            Country__c = 'United Kingdom'
        );
        Account updatedAccount = new Account(
            Id = accountId,
            Name = 'Test',
            DnB_Country__c = 'India'
        );
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<Account>{
                updatedAccount
            },
            new Map<Id, SObject>{
                oldAccount.Id => oldAccount
            }
        );

        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals(
            'You cannot select a D&B Company from a different country.',
            fflib_SObjectDomain.Errors.getAll()[0].message
        );
    }

    @isTest
    public static void derivesAccountRegionCorrectly() {
        List<Account> accounts = new List<Account>();

        Account a0 = new Account(
            Name = 'TestAcc349640',
            BillingCountryCode = 'US',
            Industry = 'Insurance'
        );

        accounts.add(a0);

        Account a1 = new Account(
            Name = 'TestAcc349641',
            BillingCountryCode = 'US',
            BillingState = 'South Dakota',
            BillingStateCode = 'SD',
            Industry = 'Others'
        );

        accounts.add(a1);

        Account a2 = new Account(
            Name = 'TestAcc349642',
            BillingCountryCode = 'US',
            BillingPostalCode = '15001',
            Industry = 'Others'
        );

        accounts.add(a2);

        Account a3 = new Account(
            Name = 'TestAcc349643',
            BillingCountryCode = 'US',
            Industry = 'Others'
        );

        accounts.add(a3);

        Account a4 = new Account(
            Name = 'TestAcc349644',
            BillingCountryCode = 'PK',
            Industry = 'Others'
        );

        accounts.add(a4);

        Account a5 = new Account(
            Name = 'TestAcc349645',
            BillingCountryCode = 'PK',
            Industry = 'Others'
        );

        accounts.add(a5);

        Account a6 = new Account(
            Name = 'TestAcc349646',
            BillingCountryCode = 'US',
            Industry = 'Insurance'
        );

        accounts.add(a6);

        Account a7 = new Account(
            Name = 'TestAcc323232',
            BillingCountryCode = 'JP',
            Industry = 'Insurance'
        );

        accounts.add(a7);

        fflib_SObjectDomain.Test.Database.onInsert(accounts);
        fflib_SObjectDomain.triggerHandler(Accounts.class);

        System.assertEquals('AMER', a0.Geo__c);
        System.assertEquals('Northwest', a1.Region__c);
        System.assertEquals('NorthCentral', a2.Region__c);
        System.assertEquals(null, a3.Region__c);
        System.assertEquals('EMEA', a4.Geo__c);
        System.assertEquals('EMEA', a5.Geo__c);
        System.assertEquals('AMER North & BFS', a6.Area__c);
        System.assertEquals('Japan', a7.Geo__c);

    }

    @isTest
    private static void setRegionSpecificFieldTest() {
        Account account1 = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'Test1',
            Geo__c = 'AMER',
            Region__c = 'North',
            Country__c = 'United States',
            BillingCountry = 'United States',
            NumberOfEmployees = 5000,
            AnnualRevenue = 500000000.00
        );
        Account oldAccount1 = new Account(
            Id = account1.Id,
            Name = 'Test1',
            Country__c = 'United States',
            BillingCountry = 'United States'
        );

        Account account2 = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'Test2',
            Geo__c = 'AMER',
            Region__c = 'North',
            Country__c = 'United States',
            BillingCountry = 'United States',
            NumberOfEmployees = 3000,
            AnnualRevenue = 1500000000.00
        );
        Account oldAccount2 = new Account(
            Id = account2.Id,
            Name = 'Test2',
            Country__c = 'United States',
            BillingCountry = 'United States'
        );

        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<Account>{
                account1, account2
            },
            new Map<Id, SObject>{
                oldAccount1.Id => oldAccount1,
                oldAccount2.Id => oldAccount2
            }
        );
        fflib_SObjectDomain.triggerHandler(Accounts.class);

        System.assertEquals(account1.Region_Specific__c, 'Velocity Tier 1');
        System.assertEquals(account2.Region_Specific__c, 'Enterprise Tier 3');
    }

    @isTest
    public static void setsAccountSubsidiaryOnInsert() {

        Account ukAccount = new Account(
            Name = 'TestAccountUK',
            Country__c = 'United Kingdom',
            BillingCountry = 'United Kingdom',
            Industry = 'Others');

        fflib_SObjectDomain.Test.Database.onInsert( new List<Account>{
            ukAccount
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);

        System.assertEquals('UiPath SRL', ukAccount.Primary_Subsidiary__c);
    }

    /* Method to test setting the Channel Tier during insert using the RecordType */
    @isTest
    public static void setsAccountChannelTierOnInsert() {

        Id partnerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Prospect').getRecordTypeId();

        Account partnerAccount = new Account(
            Name = 'TestAccountChannelTier',
            BillingCountry = 'United Kingdom',
            Industry = 'Others',
            RecordTypeId = partnerProspectRT);

        fflib_SObjectDomain.Test.Database.onInsert( new List<Account>{
            partnerAccount
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);

        System.assertEquals('Reseller', partnerAccount.Channel_Tier__c);
    }

    /* Method to test recordType assignment at creation by Account_Business_Type__c*/
    @isTest
    public static void setsAccountRecordTypeOnInsert() {

        Id partnerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Prospect').getRecordTypeId();
        Id customerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Prospect').getRecordTypeId();

        Account partnerAccount = new Account(
            Name = 'TestPartnerAccount',
            BillingCountry = 'United Kingdom',
            Industry = 'Others',
            Account_Business_Type__c = 'Partner');

        Account customerAccount = new Account(
            Name = 'TestCustomerAccount',
            BillingCountry = 'United Kingdom',
            Industry = 'Others',
            Account_Business_Type__c = 'Customer');

        fflib_SObjectDomain.Test.Database.onInsert( new List<Account>{
            partnerAccount, customerAccount
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);

        System.assertEquals(partnerProspectRT, partnerAccount.RecordTypeId);
        System.assertEquals(customerProspectRT, customerAccount.RecordTypeId);
    }

    /* Method to test recordType assignment when changing Account_Business_Type__c*/
    @isTest
    static void setsAccountRecordTypeForExistingAccount() {

        Id partnerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Prospect').getRecordTypeId();
        
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account oldAccount = new Account(
            Id = accountId,
            Name = 'AccTestSetRecordTypeForExistingAccount',
            Country__c = 'United Kingdom'
        );
        Account updatedAccount = new Account(
            Id = accountId,
            Name = 'AccTestSetRecordTypeForExistingAccount',
            Country__c = 'United Kingdom'
        );
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<Account>{
                updatedAccount
            },
            new Map<Id, SObject>{
                oldAccount.Id => oldAccount
            }
        );

        fflib_SObjectDomain.triggerHandler(Accounts.class);

        System.assertEquals(partnerProspectRT, oldAccount.RecordTypeId);
    }

    /* Method to test the Sync Status change when Account Validation Status is set to Validated*/
    @isTest
    static void setsSyncStatusForValidatedAccount() {

        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account oldAccount = new Account(
            Id = accountId,
            Name = 'AccTestSetSyncStatusForValidatedAccount',
            Country__c = 'United Kingdom'
        );
        Account updatedAccount = new Account(
            Id = accountId,
            Name = 'AccTestSetSyncStatusForValidatedAccount',
            Country__c = 'United Kingdom',
            Validation_Status__c = Constants.ACC_VALIDATION_STATUS_VALIDATED
        );
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<Account>{
                updatedAccount
            },
            new Map<Id, SObject>{
                oldAccount.Id => oldAccount
            }
        );

        fflib_SObjectDomain.triggerHandler(Accounts.class);

        System.assertEquals(Constants.ACC_SYNC_STATUS_VALID,updatedAccount.Sync_Status__c,'if Validation Status is set to Validated, then Sync Status should be set to Valid');
    }

    /**
     * Can insert 200 Accounts in Bulk without Limits issues
     */
    @IsTest
    private static void canInsertAccountsInBulk() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(
                new Account(
                    Name = 'Test ' + i,
                    BillingCountry = 'United Kingdom',
                    Industry = 'Others'
                )
            );
        }
        //will throw on any limits issues
        System.assertEquals(Database.insert(accounts, true).size() > 0, true);
    }

    /**
     * Can update 200 Accounts in Bulk without Limits issues
     */
    @IsTest
    private static void canUpdateAccountsInBulk() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(
                new Account(
                    Name = 'Test ' + i,
                    BillingCountry = 'United Kingdom',
                    Industry = 'Others'
                )
            );
        }
        insert accounts;
        for (Integer i = 0; i < 200; i++) {
            accounts.get(i).Name = 'Updated Account ' + i;
        }
        //will throw on any limits issues
        List<Database.SaveResult> results = Database.update(accounts, true);
        System.assertEquals(results.size() > 0, true);
    }


}
