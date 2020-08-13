@isTest
public with sharing class AccountSetClassificationQueueableTest {
  private static final string USA = 'United States';

  @isTest
  public static void setupClassification_UpdateTest() {
    Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Customer')
      .getRecordTypeId();

    Account topParentAcc = new Account(
      Name = 'TopParentAccount',
      Geo__c = 'APAC',
      RecordTypeId = customerRT,
      Classification__c = 'General Business',
      Country__c = USA,
      Industry = 'Communications'
    );
    insert topParentAcc;

    Account parentAccount1 = new Account(
      Name = 'Parent Account 1',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Global',
      Country__c = 'France',
      Industry = 'Communications',
      AnnualRevenue = 10000000
    );
    insert parentAccount1;

    List<Account> childrenAccounts = new List<Account>();
    Account childparentAccount11 = new Account(
      Name = 'ChildrenAccount11',
      ParentId = parentAccount1.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Global',
      Country__c = USA,
      Industry = 'Communications',
      AnnualRevenue = 10000000
    );
    childrenAccounts.add(childparentAccount11);

    Account childparentAccount12 = new Account(
      Name = 'Children Account 12',
      ParentId = parentAccount1.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Global',
      Country__c = 'Germany',
      Industry = 'Communications',
      AnnualRevenue = 10000000
    );
    childrenAccounts.add(childparentAccount12);

    Account parentAccount2 = new Account(
      Name = 'ParentAccount2',
      ParentId = topParentAcc.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Global',
      Country__c = 'Italy',
      Industry = 'Communications',
      AnnualRevenue = 10000000
    );
    insert parentAccount2;

    Account childparentAccount21 = new Account(
      Name = 'ChildrenAccount21',
      ParentId = parentAccount2.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Global',
      Country__c = 'Peru',
      Industry = 'Communications',
      AnnualRevenue = 10000000
    );
    childrenAccounts.add(childparentAccount21);

    Account childparentAccount22 = new Account(
      Name = 'Children Account 22',
      ParentId = parentAccount2.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Global',
      Country__c = USA,
      Industry = 'Communications',
      AnnualRevenue = 10000000
    );
    childrenAccounts.add(childparentAccount22);

    insert childrenAccounts;

    Account childparentAccount23 = new Account(
      Name = 'Child Account 23',
      ParentId = parentAccount2.Id,
      RecordTypeId = customerRT,
      Classification__c = 'Global',
      Country__c = 'Japan',
      Industry = 'Communications',
      AnnualRevenue = 10000000,
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
        Classification__c = 'Global',
        Country__c = 'Canada',
        Industry = 'Communications',
        AnnualRevenue = 10000000
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
      acc.Classification__c = '';

    update parentAcc;

    AccountSetClassificationQueueable accSetClassification = new AccountSetClassificationQueueable(
      new List<Account>{ parentAcc[0], parentAcc[1] }
    );
    accSetClassification.execute(null);

    List<Account> childAccountIns = [
      SELECT Id, Name, Classification__c
      FROM Account
      WHERE Classification__c != 'Global'
    ];
    System.assertEquals(7, childAccountIns.size());
  }
}
