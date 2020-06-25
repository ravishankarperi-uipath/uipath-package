
@IsTest
public with sharing class AccountsTest {

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
        System.assertEquals(account.BillingState, 'Gujarat');

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
        System.assertEquals(Database.insert(accounts,true).size()>0, true);

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

        Test.startTest();
        for (Integer i = 0; i < 200; i++) {
            accounts.get(i).Name='Updated Account ' + i;
        }
        //will throw on any limits issues
        List<Database.SaveResult> results=Database.update(accounts,true);
        Test.stopTest();
        System.assertEquals(results.size()>0, true);


    }

}