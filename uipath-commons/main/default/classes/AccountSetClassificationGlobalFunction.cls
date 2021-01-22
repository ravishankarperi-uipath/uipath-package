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
    system.debug('parentIds ======> ' + parentIds);
    parentAccounts = new Map<Id, Account>(
      [SELECT Id, Classification__c FROM Account WHERE Id IN :parentIds AND Classification__c = 'Global']
    );
  }

  public SObject apply(Account acc) {
    if (parentAccounts.containsKey(acc.ParentId)) {
      acc.Classification__c = 'Global';
      acc.Overwrite_Classification__c = true;
    } else {
      acc.Classification__c = '';
      acc.Overwrite_Classification__c = false;
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  public static void deriveRecordTypeOnInsert(List<Account> records) {
    Collection.of(records)
      .mapSome(Match.field(Account.ParentId).hasValue(), new AccountSetClassificationGlobalFunction(records));
  }

  public static void deriveRecordTypeOnUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.ParentId },
      accounts,
      existingAccounts
    );

    List<Account> changedAccounts = Collection.of(accounts)
      .filter(hasChanged)
      .filter(
        Match.field(Account.RecordTypeId)
          .isIn(
            new Set<String>{
              AccountMetadata.customerRecordType,
              AccountMetadata.customerProspectRecordType,
              AccountMetadata.ProspectRecordType,
              null
            }
          )
      )
      .asList();

    if (!changedAccounts.isEmpty()) {
      system.debug('changedAccounts ======> ' + changedAccounts);
      Collection.of(changedAccounts).mapAll(new AccountSetClassificationGlobalFunction(changedAccounts));
    }
  }
}
