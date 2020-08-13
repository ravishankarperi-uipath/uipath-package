public with sharing class AccountSetClassificationQueueable extends AbstractQueueable {
  private final List<SObject> accounts;

  public AccountSetClassificationQueueable(List<SObject> accounts) {
    super('AccountSetClassificationQueueable');
    this.accounts = accounts;
  }

  public override void work() {
    this.setFormulaClassificationOnChildren(this.accounts);
  }
  private void setFormulaClassificationOnChildren(List<SObject> accounts) {
    List<Id> recordTypesOfInterest = new List<Id>{
      AccountMetadata.customerRecordType,
      AccountMetadata.customerProspectRecordType,
      AccountMetadata.ProspectRecordType
    };
    List<Account> children = [
      SELECT
        Id,
        Name,
        Parent.Overwrite_Classification__c,
        Parent.Parent.Overwrite_Classification__c
      FROM Account
      WHERE
        (Parent.Parent.Parent.Id IN :accounts
        OR Parent.Parent.Id IN :accounts
        OR Parent.Id IN :accounts)
        AND RecordTypeId IN :recordTypesOfInterest
        AND Classification__c = 'Global'
        AND Overwrite_Classification__c = false
    ];

    for (Account acc : children) {
      if (
        acc.Parent.Overwrite_Classification__c == false &&
        acc.Parent.Parent.Overwrite_Classification__c == false
      )
        acc.Classification__c = '';
    }
    update children;
  }

  /**
   * For non-global accounts, when an Account Classification changes from 'Global' to the formula based on AnnualRevenue, Geo and Region set all children accounts to follow the
   * @param accounts
   * @param existingAccounts
   */
  public static void setClassificationByGeoAndRevenue(
    List<Account> accounts,
    Map<Id, SObject> existingAccounts
  ) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.Classification__c },
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
          .also(Account.Classification__c)
          .notEquals('Global')
          .also(Account.Overwrite_Classification__c)
          .equals(false)
          .also(Account.AnnualRevenue)
          .notEquals(null)
      )
      .asList();

    if (!changedAccounts.isEmpty()) {
      AbstractQueueable.enqueue(
        new AccountSetClassificationQueueable(changedAccounts)
      );
    }
  }
}
