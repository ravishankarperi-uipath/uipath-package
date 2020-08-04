/**
 * TODO - more code refactoring in 2 pass
 * Share account using OwnerFromLead field
 * Code moved from CommunityAccountTrigger into Queueable
 */
@SuppressWarnings('PMD')
public with sharing class AccountSharingLeadOwnerQueueable extends AbstractQueueable {
  private final List<SObject> accountsLst;

  public AccountSharingLeadOwnerQueueable(List<SObject> accountsLst) {
    super('AccountSharingLeadOwnerQueueable');
    this.accountsLst = accountsLst;
  }

  public override void work() {
    this.shareAccountWithLeadOwner(this.accountsLst);
    this.clearOwnerFromLead(this.accountsLst);
  }

  private void shareAccountWithLeadOwner(List<Account> accountList) {
    Set<ID> leadOwnerIdSet = new Set<ID>();
    for (Account acc : accountList) {
      if (String.isNotEmpty(acc.OwnerFromLead__c)) {
        leadOwnerIdSet.add(acc.OwnerFromLead__c);
      }
    }

    if (!leadOwnerIdSet.isEmpty()) {
      // リード所有者の取引先ID取得
      Map<ID, User> leadOwnerMap = new Map<ID, User>(
        [
          SELECT Id, Contact.AccountId
          FROM User
          WHERE IsActive = true AND Id IN :leadOwnerIdSet
        ]
      );

      if (!leadOwnerMap.isEmpty()) {
        Set<ID> accIdSet = new Set<ID>();
        for (User u : leadOwnerMap.values()) {
          accIdSet.add(u.Contact.AccountId);
        }

        // 同一取引先所属のユーザ取得
        List<User> communityUserAccList = [
          SELECT Id, ContactId, Contact.AccountId
          FROM User
          WHERE IsActive = true AND Contact.AccountId IN :accIdSet
        ];

        List<AccountShare> accShareList = new List<AccountShare>();

        for (Account acc : accountList) {
          if (String.isNotEmpty(acc.OwnerFromLead__c)) {
            // 所有者の所属取引先
            ID ownerAccId = leadOwnerMap.get(acc.OwnerFromLead__c)
              .Contact.AccountId;

            // 同一取引先所属のユーザに共有設定
            for (User u : communityUserAccList) {
              if (u.ContactId != null && ownerAccId == u.Contact.AccountId) {
                accShareList.add(
                  new AccountShare(
                    AccountId = acc.Id,
                    UserOrGroupId = u.Id,
                    AccountAccessLevel = 'Read',
                    OpportunityAccessLevel = 'None'
                  )
                );
              }
            }
          }
        }

        if (!accShareList.isEmpty()) {
          insert accShareList;
        }
      }
    }
  }

  private void clearOwnerFromLead(List<Account> accountsLst) {
    List<Account> updAccList = new List<Account>();

    for (Account acc : accountsLst) {
      if (String.isNotEmpty(acc.OwnerFromLead__c)) {
        updAccList.add(new Account(Id = acc.Id, OwnerFromLead__c = null));
      }
    }

    if (!updAccList.isEmpty()) {
      update updAccList;
    }
  }

  /**
   * Share account using OwnerFromLead field
   */
  public static void shareAccount(List<Account> records) {
    List<Account> eligibleAccounts = (List<Account>) Collection.of(records)
      .filter(Match.field(Account.OwnerFromLead__c).hasValue())
      .asList();
    if (!eligibleAccounts.isEmpty()) {
      AbstractQueueable.enqueue(
        new AccountSharingLeadOwnerQueueable(eligibleAccounts)
      );
    }
  }

  /**
   * Share account using OwnerFromLead field
   */
  public static void shareAccountOnUpdate(
    List<Account> accounts,
    Map<Id, SObject> existingAccounts
  ) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.OwnerFromLead__c },
      accounts,
      existingAccounts
    );

    List<Account> eligibleAccounts = (List<Account>) Collection.of(accounts)
      .filter(Match.field(Account.OwnerFromLead__c).hasValue())
      .filter(hasChanged)
      .asList();
    if (!eligibleAccounts.isEmpty()) {
      AbstractQueueable.enqueue(
        new AccountSharingLeadOwnerQueueable(eligibleAccounts)
      );
    }
  }
}
