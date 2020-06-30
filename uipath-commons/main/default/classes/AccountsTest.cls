
@IsTest
public class AccountsTest {

    @IsTest
    private static void validatesStateRequiredForChinaAustralia() {
        Accounts accounts = new Accounts(new Account[]{
            new Account (Name = 'Test', Country__c = 'China', State__c = null)
        });
        accounts.onValidate();
        System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());
        System.assertEquals('State is required if Country is China', fflib_SObjectDomain.Errors.getAll()[0].message);
        System.assertEquals(Account.State__c, ((fflib_SObjectDomain.FieldError) fflib_SObjectDomain.Errors.getAll()[0]).field);
    }

    @IsTest
    private static void copiesStateToBillingStateIfCountryNotChinaAustralia() {
        Account account = new Account (Name = 'Test', Country__c = 'India', State__c = 'Gujarat');
        fflib_SObjectDomain.Test.Database.onInsert(new Account[]{
            account
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('Gujarat', account.BillingState);
    }

    @IsTest
    private static void copiesCountryToBillingCountryOnlyIfNotAlreadySet() {
        Account accountA = new Account (Name = 'Test', Country__c = 'India', State__c = 'Gujarat');
        fflib_SObjectDomain.Test.Database.onInsert(new Account[]{
            accountA
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('India', accountA.BillingCountry);

        // If already set, leave it as it is
        Account accountB = new Account (Name = 'Test', Country__c = 'India', State__c = 'Gujarat', BillingCountry = 'United Kingdom');
        fflib_SObjectDomain.Test.Database.onInsert(new Account[]{
            accountB
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('United Kingdom', accountB.BillingCountry);
    }

    @IsTest
    private static void derivesCountryFromCountryCodeOnlyIfNotAlreadySet() {
        Account accountA = new Account (Name = 'Test', BillingCountryCode = 'IN');
        fflib_SObjectDomain.Test.Database.onInsert(new Account[]{
            accountA
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('India', accountA.BillingCountry);

        // If already set, leave it as it is
        Account accountB = new Account (Name = 'Test', BillingCountryCode = 'IN', BillingCountry = 'United Kingdom');
        fflib_SObjectDomain.Test.Database.onInsert(new Account[]{
            accountB
        });
        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('United Kingdom', accountB.BillingCountry);

    }

    @IsTest
    private static void copiesAddressFromDnB() {

        Account accountA = new Account (Name = 'Test',
            DnB_Country__c = 'United Kingdom',
            DnB_Street__c = '21 Maple Mews',
            DnB_City__c = 'London',
            DnB_Zip_Postal_Code__c = 'SW16 2AL',
            DnB_State_Province__c = 'Surrey'
        );
        fflib_SObjectDomain.Test.Database.onInsert(new Account[]{
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
        Account oldAccount = new Account (Id = accountId, Name = 'Test', Country__c = 'United Kingdom'
        );
        Account updatedAccount = new Account (Id = accountId, Name = 'Test',
            DnB_Country__c = 'India'
        );
        fflib_SObjectDomain.Test.Database.onUpdate(new Account[]{
            updatedAccount
        }, new Map<Id, SObject>{
            oldAccount.Id => oldAccount
        });

        fflib_SObjectDomain.triggerHandler(Accounts.class);
        System.assertEquals('You cannot select a D&B Company from a different country.', fflib_SObjectDomain.Errors.getAll()[0].message);
    }

    /**
     * Can insert 200 Accounts in Bulk without Limits issues
     */
    @IsTest
    private static void canInsertAccountsInBulk() {

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account (Name = 'Test ' + i, BillingCountry = 'United Kingdom', Industry = 'Others'));

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
            accounts.add(new Account (Name = 'Test ' + i, BillingCountry = 'United Kingdom', Industry = 'Others'));

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