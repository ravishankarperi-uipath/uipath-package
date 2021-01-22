@IsTest
public class SalesCaseBillToWOOppFunctionTest {
  @IsTest
  private static void testUpdateBillWOOpsToOnInsert() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id legalRequestRecordTypeId = SalesCaseMetadata.LegalRequestRecordType;

    Account acc = new Account(
      Id = accountId,
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      Industry = 'Others'
    );

    Case cs = new Case(
      AccountId = accountId,
      Id = caseId,
      Subject = 'Case1',
      RecordTypeId = legalRequestRecordTypeId,
      Status = 'New'
    );

    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ cs });

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals(cs.AccountId, cs.Bill_To__c);
  }

  @IsTest
  private static void testUpdateBillWOOpsToOnUpdate() {
    Id legalRequestRecordTypeId = SalesCaseMetadata.LegalRequestRecordType;

    List<Account> accounts = new List<Account>();

    Account oldAccount = new Account(
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      Industry = 'Others'
    );
    accounts.add(oldAccount);

    Account newAccount = new Account(
      Name = 'TestAccountUK2',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      Industry = 'Others'
    );
    accounts.add(newAccount);
    insert accounts;

    Case cs = new Case(
      AccountId = oldAccount.Id,
      Bill_To__c = oldAccount.Id,
      Subject = 'Case1',
      RecordTypeId = legalRequestRecordTypeId,
      Status = 'New'
    );

    insert cs;

    Test.startTest();
    cs.AccountId = newAccount.Id;
    update cs;

    Case updatedCase = [SELECT Bill_To__r.Name FROM Case WHERE Id = :cs.Id LIMIT 1];
    System.assertEquals('TestAccountUK2', updatedCase.Bill_To__r.Name);
    Test.stopTest();
  }
}
