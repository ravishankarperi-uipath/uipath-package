/**
 * Sets Classification to "Global" if Parent Account Classification is "Global" on insert
 */
public with sharing class AccountSetClassificationGlobalFunction implements SObjectToSObjectFunction {
  private Map<Id, Account> parentAccounts;

  public AccountSetClassificationGlobalFunction(List<Account> accounts) {
    Set<Id> parentIds = new Set<Id>();
    for (Account acc : accounts) {
      parentIds.add(acc.ParentId);
    }
    parentAccounts = new Map<Id, Account>(
      [
        SELECT Id, Classification__c
        FROM Account
        WHERE Id IN :parentIds AND Classification__c = 'Global'
      ]
    );
  }

  public SObject apply(Account acc) {
    if (parentAccounts.containsKey(acc.ParentId)) {
      acc.Classification__c = 'Global';
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  public static void deriveRecordTypeOnInsert(List<Account> records) {
    Collection.of(records)
      .mapSome(
        Match.field(Account.ParentId).hasValue(),
        new AccountSetClassificationGlobalFunction(records)
      );
  }
}
