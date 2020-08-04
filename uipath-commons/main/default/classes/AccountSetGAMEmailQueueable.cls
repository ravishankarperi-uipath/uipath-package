public with sharing class AccountSetGAMEmailQueueable extends AbstractQueueable {
  /**
   * Set GAM Email field on account
   * If account Classification is Global populates GAM Email with UltimateAccount.Owner.Email
   */

  private final List<SObject> accountsLst;
  private final Map<Id, SObject> oldAccountsMap;

  public AccountSetGAMEmailQueueable(
    List<SObject> accountsLst,
    Map<Id, SObject> oldAccountsMap
  ) {
    super('AccountSetGAMEmailQueueable');
    this.accountsLst = accountsLst;
    this.oldAccountsMap = oldAccountsMap;
  }

  public override void work() {
    this.setGAMEamil(this.accountsLst, this.oldAccountsMap);
  }

  private void setGAMEamil(
    List<SObject> accountsLst,
    Map<Id, SObject> oldAccountsMap
  ) {
    List<Account> accounts = (List<Account>) accountsLst;
    if (oldAccountsMap == null)
      accounts = [
        SELECT Id, ParentId, Classification__c, Ultimate_Parent_Id__c
        FROM Account
        WHERE Id IN :accounts
      ];

    Map<String, List<Account>> topParentAndChildrenMap = new Map<String, List<Account>>();

    for (Account acc : accounts) {
      Account oldAcc = null;
      if (null != oldAccountsMap)
        oldAcc = (Account) oldAccountsMap.get(acc.Id);

      if (
        acc.Classification__c == 'Global' ||
        acc.ParentId == null ||
        oldAcc.Classification__c == 'Global'
      ) {
        /**
         * initialize a map with Key = Ultimate parent Id and value = new List<Account> to add all children Accounts
         **/
        string ultimateParentId = acc.ParentId == null
          ? ((String) acc.Id).substring(0, 15)
          : acc.Ultimate_Parent_Id__c;
        topParentAndChildrenMap.put(ultimateParentId, new List<Account>());
      }
    }

    if (topParentAndChildrenMap.size() > 0) {
      /**
       * Select Ultimate parent accounts and all their children
       **/
      List<Account> allAccounts = [
        SELECT
          Id,
          Classification__c,
          OwnerId,
          Owner.Email,
          ParentId,
          Ultimate_Parent_Id__c
        FROM Account
        WHERE
          Id IN :topParentAndChildrenMap.keySet()
          OR Ultimate_Parent_Id__c IN :topParentAndChildrenMap.keySet()
      ];

      /**
       * create a map with key - ultimate account id and value - ultimate account owner email
       **/

      Map<String, String> topParentOwnerEmail = getUltimateAccountOwnerEmail(
        allAccounts
      );
      /**
       * populate topParentAndChildrenMap with a list of children accounts for each Ultimate parent
       **/

      Map<String, List<Account>> topParentChildrenMap = getUltimateAccountChildren(
        allAccounts,
        topParentAndChildrenMap
      );

      /**
       * set up GAM_Email__c for all children with Classification = 'Global'
       **/

      List<Account> AccountsToUpdate = new List<Account>();
      for (String topid : topParentOwnerEmail.keySet()) {
        List<Account> children = topParentChildrenMap.get(topid);
        for (Account acc : children) {
          acc.GAM_Email__c = acc.Classification__c == 'Global'
            ? topParentOwnerEmail.get(topid)
            : '';
          AccountsToUpdate.add(acc);
        }
      }

      if (AccountsToUpdate.size() > 0)
        update AccountsToUpdate;
    }
  }

  private static Map<String, List<Account>> getUltimateAccountChildren(
    List<Account> allAccounts,
    Map<String, List<Account>> ultimateAccountsMap
  ) {
    for (Account acc : allAccounts) {
      /**
       *  populate topParentAndChildrenMap with a list of children accounts for each Ultimate parent
       **/

      if (ultimateAccountsMap.containsKey(acc.Ultimate_Parent_Id__c)) {
        List<Account> childrenAccList = ultimateAccountsMap.get(
          acc.Ultimate_Parent_Id__c
        );
        childrenAccList.add(acc);
        ultimateAccountsMap.put(acc.Ultimate_Parent_Id__c, childrenAccList);
      }
    }
    return ultimateAccountsMap;
  }

  private static Map<String, String> getUltimateAccountOwnerEmail(
    List<Account> allAccounts
  ) {
    Map<String, String> topParentMap = new Map<String, String>();
    for (Account acc : allAccounts)
      if (acc.ParentId == null)
        topParentMap.put(((String) acc.Id).substring(0, 15), acc.Owner.Email);
    return topParentMap;
  }

  /**
   * For global accounts, set up GAM Email Account to Ultimate Parent Account Owner.Email
   * @param accounts
   * @param existingAccounts
   */
  public static void setGAMEmailOnGlobalAccounts(
    List<Account> accounts,
    Map<Id, SObject> existingAccounts
  ) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.Classification__c,
        Account.OwnerId,
        Account.ParentId
      },
      accounts,
      existingAccounts
    );
    List<Account> eligibleAccounts = (List<Account>) Collection.of(accounts)
      .filter(hasChanged)
      .asList();

    if (!eligibleAccounts.isEmpty()) {
      AbstractQueueable.enqueue(
        new AccountSetGAMEmailQueueable(eligibleAccounts, existingAccounts)
      );
    }
  }
}
