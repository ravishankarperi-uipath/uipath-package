/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 */
public with sharing class AccountSharingRollupQueueable extends QueueableWrapper {
    private final List<SObject> accountsLst;
    private final Map<Id, SObject> oldAccountsMap;

    public AccountSharingRollupQueueable(
            List<SObject> accountsLst,
            Map<Id, SObject> oldAccountsMap
    ) {
        super('AccountSharingRollupQueueable');
        this.accountsLst = accountsLst;
        this.oldAccountsMap = oldAccountsMap;
    }

    public override void work() {
        this.grantPermissionToParentOwner(this.accountsLst, this.oldAccountsMap);
    }

    /**
     * TODO REWRITE
     * This method was just moved here from a trigger context to support our efforts to break the transaction
     * @param accountsLst
     * @param oldAccountsMap
     */
    private void grantPermissionToParentOwner(
            List<SObject> accountsLst,
            Map<Id, SObject> oldAccountsMap
    ) {

        System.debug('******grantPermissionToParentOwner*****');

        //Type casted to the Account list from SObject
        List<Account> accounts = (List<Account>) accountsLst;
        Account accOldObj;

        Map<Id, Account> topHAccounts = new Map<Id, Account>();
        Set<Id> accChildrenIds = new Set<Id>();
        if (accounts != null && accounts.size() > 0) {
            for (Account acc : accounts) {
                //check was inserted or was updated and the owner/account_parent were changed
                if (null != oldAccountsMap) {
                    accOldObj = (Account) oldAccountsMap.get(acc.Id);
                }
                if (
                        acc.Classification__c == 'Global' &&
                                (oldAccountsMap != null &&
                                        (accOldObj.OwnerId != acc.OwnerId ||
                                                accOldObj.ParentId != acc.ParentId) || oldAccountsMap == null)
                        ) {
                    if (acc.ParentId != null) {
                        System.debug('******found parent*****');
                        accChildrenIds.add(acc.ParentId);
                    }

                    else
                            topHAccounts.put(acc.ID, acc);
                }
            } //end for
        }

        if (accChildrenIds != null && accChildrenIds.size() > 0) {
            //get top hierarchy accounts
            do {
                List<Account> parents = [
                        SELECT Id, ParentId, OwnerId
                        FROM Account
                        WHERE ID IN :accChildrenIds
                ];
                accChildrenIds = new Set<Id>(); //remove all ids from list to add new children

                for (Account acc : parents) {
                    if (acc.ParentId != null)
                        accChildrenIds.add(acc.ParentId); else
                            topHAccounts.put(acc.Id, acc);
                } //end for
            } while (accChildrenIds.size() > 0);
        }

//get top parent owner
        Map<Id, Id> accParentIdOwnerId = new Map<Id, Id>();
        for (Account acc : topHAccounts.values()) {
            accParentIdOwnerId.put(acc.Id, acc.OwnerId);
        } //end for

        this.GrantPermissions(accParentIdOwnerId);
    }

    /**
     * @Description: This method is created by UiPath.
     */
    private void grantPermissions(Map<Id, Id> accParentIdOwnerId) {
//Generate Account Share records
        List<AccountShare> accShareToInsert = new List<AccountShare>();
        List<Account> children = new List<Account>();

        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^' + accParentIdOwnerId.keySet());
        do {
            children = [
                    SELECT Id, ParentId, OwnerId
                    FROM Account
                    WHERE ParentId IN :accParentIdOwnerId.keySet()
            ];
            Set<Id> usedIds = new Set<Id>();
            usedIds.addAll(accParentIdOwnerId.keySet());

            if (children != null && children.size() > 0) {
                for (Account acc : children) {
                    if (acc.OwnerId != accParentIdOwnerId.get(acc.ParentId)) {
                        AccountShare accShare = new AccountShare();
                        accShare.AccountAccessLevel = 'Edit';
                        accShare.AccountId = acc.Id;
//accShare.ContactAccessLevel = 'Edit'; // Contact org-wide default is set to "Controlled by Parent"
                        accShare.OpportunityAccessLevel = 'Edit';
                        accShare.UserOrGroupId = accParentIdOwnerId.get(acc.ParentId);

                        accShareToInsert.add(accShare);

//relate ownerId to children - keeping it through hirarchi
                        accParentIdOwnerId.put(
                                acc.Id,
                                accParentIdOwnerId.get(acc.ParentId)
                        );
                    }
                } //end for
            }
//remove existing record to carry on just the useful information
            for (Id parentId : usedIds) {
                accParentIdOwnerId.remove(parentId);
            } //end for
        } while (children.size() > 0);

        if (accShareToInsert != null && accShareToInsert.size() > 0) {
            insert accShareToInsert;
            System.debug('accShareToInsert' + accShareToInsert);
        }


    }
}
