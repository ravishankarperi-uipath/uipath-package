/**
 * Sets Sync Status on each account. This drives integration logic in Boomi
 */
public class AccountSetSyncStatusFunction implements SObjectToSObjectFunction {
  private Map<Id, SObject> oldAccounts;

  public AccountSetSyncStatusFunction(Map<Id, SObject> oldAccounts) {
    this.oldAccounts = oldAccounts;
  }

  public SObject apply(Account acc) {
    Account oldAcc = (Account) oldAccounts.get(acc.Id);
    if (
      (accountStatusNotDoNotSync(oldAcc)) &&
      (validationStatusChanged(oldAcc, acc)) &&
      (ValidationStatusSetToValidated(acc))
    ) {
      if (accountAlreadyExistsInNetsuite(acc)) {
        acc.Sync_Status__c = CommonsConstants.ACC_SYNC_STATUS_PENDING;
      } else {
        acc.Sync_Status__c = CommonsConstants.ACC_SYNC_STATUS_VALID;
      }
    }
    return acc;
  }

  private Boolean accountAlreadyExistsInNetsuite(Account acc) {
    return null != acc.NS_Customer_Internal_ID__c;
  }

  private Boolean ValidationStatusSetToValidated(Account acc) {
    return acc.Validation_Status__c ==
      CommonsConstants.ACC_VALIDATION_STATUS_VALIDATED;
  }

  private Boolean validationStatusChanged(Account oldAcc, Account acc) {
    return oldAcc.Validation_Status__c != acc.Validation_Status__c;
  }

  private Boolean accountStatusNotDoNotSync(Account oldAcc) {
    return oldAcc.Sync_Status__c !=
      CommonsConstants.ACC_SYNC_STATUS_DO_NOT_SYNC;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  public static void deriveSyncStatusForValidatedAccount(
    List<Account> accounts,
    Map<Id, SObject> existingAccounts
  ) {
    SObjectPredicate haveStatusesChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.Sync_Status__c,
        Account.Validation_Status__c
      },
      accounts,
      existingAccounts
    );

    Collection.of(accounts)
      .filter(haveStatusesChanged)
      .mapAll(new AccountSetSyncStatusFunction(existingAccounts));
  }
}
