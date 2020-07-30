/**
 * Responsibility: If account Classification is Global change all children to global
 */
public with sharing class AccountClassificationGlobalQueueable extends AbstractQueueable {
  private final List<SObject> accounts;

  public AccountClassificationGlobalQueueable(List<SObject> accounts) {
    super('AccountClassificationGlobalQueueable');
    this.accounts = accounts;
  }

  public override void work() {
    this.setGlobalClassificationOnChildren(this.accounts);
  }

  private void setGlobalClassificationOnChildren(List<SObject> accounts) {
    List<Id> recordTypesOfInterest = new List<Id>{
      AccountMetadata.customerRecordType,
      AccountMetadata.customerProspectRecordType,
      AccountMetadata.ProspectRecordType
    };

    List<Account> children = [
      SELECT Id, Name
      FROM Account
      WHERE
        (Parent.Parent.Parent.Id IN :accounts
        OR Parent.Parent.Id IN :accounts
        OR Parent.Id IN :accounts)
        AND RecordTypeId IN :recordTypesOfInterest
        AND Classification__c != 'Global'
    ];

    for (Account acc : children) {
      acc.Classification__c = 'Global';
    }
    update children;
  }
}
