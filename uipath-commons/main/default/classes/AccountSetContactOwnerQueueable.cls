/**
 * TODO REWRITE
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 */
public with sharing class AccountSetContactOwnerQueueable extends AbstractQueueable {
  private final List<SObject> accountsLst;
  private final Map<Id, SObject> oldAccountsMap;

  public AccountSetContactOwnerQueueable(List<SObject> accountsLst, Map<Id, SObject> oldAccountsMap) {
    super('AccountSetContactOwnerQueueable');
    this.accountsLst = accountsLst;
    this.oldAccountsMap = oldAccountsMap;
  }

  public override void work() {
    this.setUpContactOwner(this.accountsLst, oldAccountsMap);
  }

  // ============================================================================
  // added by Mirela Chituc - 5/26/2020 ========================================
  // Set up Account Owner as Contact Owner to all Conatcts - after update
  // ============================================================================
  private void setUpContactOwner(List<Account> accountList, Map<Id, SObject> oldAccountMap) {
    Set<Id> accIds = new Set<Id>();
    for (Account acc : accountList) {
      Account oldAcc = (Account) oldAccountMap.get(acc.Id);
      if (acc.OwnerId != oldAcc.OwnerId && acc.PG_Legacy__c == false)
        accIds.add(acc.Id);
    }

    if (accIds.size() > 0) {
      List<Account> allAccounts = [
        SELECT Id, OwnerId, GAM_Id__c, EDR__c, (SELECT Id, OwnerId FROM Contacts)
        FROM Account
        WHERE Id IN :accIds AND PG_Legacy__c = false AND Country__c != 'Japan'
      ];

      List<Contact> cntToUpdate = new List<Contact>();
      for (Account acc : allAccounts) {
        for (contact cnt : acc.Contacts) {
          String cntOwner = String.valueOf(cnt.OwnerId);
          cntOwner = cntOwner.substring(0, 15);
          if (cntOwner != acc.GAM_Id__c && cnt.OwnerId != acc.EDR__c && cnt.OwnerId != acc.OwnerId) {
            cnt.OwnerId = acc.OwnerId;
            cntToUpdate.add(cnt);
          }
        }
      }
      if (cntToUpdate.size() > 0)
        update cntToUpdate;
    }
  }

  /**
   * Loop and set Owner on all contacts to the owner of Account
   * @param existingRecords
   */
  public static void setContactOwnerToAccountOwner(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.OwnerId },
      accounts,
      existingAccounts
    );
    List<Account> eligibleAccounts = (List<Account>) Collection.of(accounts)
      .filter(Match.field(Account.OwnerId).hasValue())
      .filter(hasChanged)
      .asList();

    if (eligibleAccounts.size() > 0) {
      AbstractQueueable.enqueue(new AccountSetContactOwnerQueueable(eligibleAccounts, existingAccounts));
    }
  }
}
