@isTest
public with sharing class AccountClassificationGlobalQueueableTest {
  private static final string USA = 'United States';

  @isTest
  public static void setupClassification_InsertTest() {
    Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    Account topParentAcc = new Account(
      Name = 'TopParentAccount',
      Geo__c = 'APAC',
      RecordTypeId = customerRT,
      Classification__c = 'General Business',
      Country__c = USA,
      BillingCountry = USA,
      Industry = 'Communications'
    );
    insert topParentAcc;

    Account parentAccount = new Account(
      Name = 'Parent Account',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Global',
      Country__c = 'France',
      BillingCountry = USA,
      Industry = 'Communications',
      Overwrite_Classification__c = true
    );
    insert parentAccount;

    Account parentAccount1 = [
      SELECT Id, Classification__c, Overwrite_Classification__c
      FROM Account
      WHERE Id = :parentAccount.Id
      LIMIT 1
    ];
    parentAccount1.Classification__c = 'Global';
    parentAccount1.Overwrite_Classification__c = true;
    update parentAccount1;

    Account childparentAccount = new Account(
      Name = 'ChildrenAccount11',
      ParentId = parentAccount1.Id,
      RecordTypeId = customerRT,
      Country__c = USA,
      BillingCountry = USA,
      Industry = 'Communications',
      Overwrite_Classification__c = false
    );

    fflib_SObjectDomain.Test.Database.onInsert(new List<Account>{ childparentAccount });
    fflib_SObjectDomain.triggerHandler(Accounts.class);
    System.assertEquals('Global', childparentAccount.Classification__c);

    Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
    Account childAccount = new Account(
      Id = accountId,
      Name = 'ChildrenAccount11',
      RecordTypeId = customerRT,
      Country__c = USA,
      BillingCountry = USA,
      Industry = 'Communications',
      ParentId = childparentAccount.Id
    );

    Account childAccountOld = new Account(
      Id = accountId,
      Name = 'ChildrenAccount11',
      RecordTypeId = customerRT,
      Country__c = USA,
      BillingCountry = USA,
      Industry = 'Communications'
    );

    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Account>{ childAccount },
      new Map<Id, SObject>{ childAccountOld.Id => childAccountOld }
    );
    fflib_SObjectDomain.triggerHandler(Accounts.class);
  }

  @isTest
  public static void setupClassification_Update2Test() {
    Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    Account topParentAcc = new Account(
      Name = 'TopParentAccount',
      Geo__c = 'APAC',
      RecordTypeId = customerRT,
      Classification__c = 'General Business',
      Country__c = USA,
      BillingCountry = USA,
      Industry = 'Communications'
    );
    insert topParentAcc;

    Account parentAccount1 = new Account(
      Name = 'Parent Account 1',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = 'France',
      BillingCountry = 'France',
      Industry = 'Communications',
      Overwrite_Classification__c = true
    );
    insert parentAccount1;

    List<Account> childrenAccounts = new List<Account>();
    Account childparentAccount11 = new Account(
      Name = 'ChildrenAccount11',
      ParentId = parentAccount1.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = USA,
      BillingCountry = USA,
      Industry = 'Communications',
      Overwrite_Classification__c = true
    );
    childrenAccounts.add(childparentAccount11);

    Account childparentAccount12 = new Account(
      Name = 'Children Account 12',
      ParentId = parentAccount1.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = 'Germany',
      BillingCountry = 'Germany',
      Industry = 'Communications',
      Overwrite_Classification__c = true
    );
    childrenAccounts.add(childparentAccount12);

    Account parentAccount2 = new Account(
      Name = 'ParentAccount2',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = 'Italy',
      BillingCountry = 'Italy',
      Industry = 'Communications',
      Overwrite_Classification__c = true
    );
    insert parentAccount2;

    Account childparentAccount21 = new Account(
      Name = 'ChildrenAccount21',
      ParentId = parentAccount2.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = 'Peru',
      BillingCountry = 'Peru',
      Industry = 'Communications',
      Overwrite_Classification__c = true
    );
    childrenAccounts.add(childparentAccount21);

    Account childparentAccount22 = new Account(
      Name = 'Children Account 22',
      ParentId = parentAccount2.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = USA,
      BillingCountry = USA,
      Industry = 'Communications',
      Overwrite_Classification__c = true
    );
    childrenAccounts.add(childparentAccount22);

    insert childrenAccounts;

    Account childparentAccount23 = new Account(
      Name = 'Child Account 23',
      ParentId = parentAccount2.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = 'Japan',
      BillingCountry = 'Japan',
      Industry = 'Communications',
      Overwrite_Classification__c = true
    );
    insert childparentAccount23;

    List<Account> childrenAccounts2 = new List<Account>();
    Account a = new Account();
    for (Integer i = 1; i < 5; i++) {
      a = new Account(
        Name = string.valueOf(i) + 'A Children Account 23',
        ParentId = childparentAccount23.Id,
        RecordTypeId = customerRT,
        Classification__c = 'Velocity',
        Country__c = 'Canada',
        BillingCountry = 'Canada',
        Industry = 'Communications',
        Overwrite_Classification__c = true
      );
      childrenAccounts2.add(a);
    }
    insert childrenAccounts2;

    List<Account> parentAcc = [
      SELECT Id, Name, Classification__c
      FROM Account
      WHERE Name = 'Parent Account 1' OR Name = 'ParentAccount2'
    ];
    for (Account acc : parentAcc)
      acc.Classification__c = 'Global';

    update parentAcc;

    AccountClassificationGlobalQueueable accSetClassificationGlobal = new AccountClassificationGlobalQueueable(
      new List<Account>{ parentAcc[0], parentAcc[1] }
    );
    accSetClassificationGlobal.execute(null);

    List<Account> childAccountIns = [
      SELECT Id, Name, Classification__c
      FROM Account
      WHERE Classification__c = 'Global'
    ];
    System.assertEquals(11, childAccountIns.size());
  }

  @IsTest
  public static void temp() {
    Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    Account topParentAcc = new Account(
      Name = 'TopParentAccount',
      Geo__c = 'APAC',
      RecordTypeId = customerRT,
      Classification__c = 'General Business',
      Country__c = USA,
      Industry = 'Communications'
    );
    insert topParentAcc;

    Account child1 = new Account(
      Name = 'child1',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = 'France',
      Industry = 'Communications'
    );
    insert child1;

    Account grandchild1 = new Account(
      Name = 'grandchild1',
      ParentId = child1.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = 'France',
      Industry = 'Communications'
    );
    insert grandchild1;

    Account greatgrandchild1 = new Account(
      Name = 'greatgrandchild1',
      ParentId = grandchild1.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Velocity',
      Country__c = 'France',
      Industry = 'Communications'
    );
    insert greatgrandchild1;

    List<Account> accounts = [
      SELECT id, name
      FROM Account
      WHERE
        Parent.Parent.Parent.Id IN :new List<Account>{ topParentAcc }
        OR Parent.Parent.Id IN :new List<Account>{ topParentAcc }
        OR Parent.Id IN :new List<Account>{ topParentAcc }
    ];

    for (Account account : accounts) {
      System.debug('======' + account.name);
    }
  }
}
