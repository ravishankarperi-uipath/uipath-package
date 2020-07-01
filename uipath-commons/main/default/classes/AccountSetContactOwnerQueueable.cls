/**
 * TODO REWRITE
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 */
public with sharing class AccountSetContactOwnerQueueable extends AbstractQueueable {
    private final List<SObject> accountsLst;
    private final Map<Id, SObject> oldAccountsMap;

    public AccountSetContactOwnerQueueable(
            List<SObject> accountsLst,
            Map<Id, SObject> oldAccountsMap
    ) {
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
        SELECT Id, OwnerId, GAM_Id__c, (SELECT Id, OwnerId FROM Contacts)
        FROM Account
        WHERE Id IN :accIds
      ];

      List<Contact> cntToUpdate = new List<Contact>();
      for (Account acc : allAccounts) {
        for (contact cnt : acc.Contacts) {
          if (String.valueOf(cnt.OwnerId).substring(0, 15) != acc.GAM_Id__c && cnt.OwnerId != acc.OwnerId) {
            cnt.OwnerId = acc.OwnerId;
            cntToUpdate.add(cnt);
          }
        }
      }

      if (cntToUpdate.size() > 0)
        update cntToUpdate;
    }
  }
}