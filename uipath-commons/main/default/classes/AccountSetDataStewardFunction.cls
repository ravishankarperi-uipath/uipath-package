/**
 * Populate Assigned Data Steward field with current user when Data Steward is checked
 * *Org-cleanup : Process Builder - Populate Data Steward
 */
public with sharing class AccountSetDataStewardFunction implements SObjectToSObjectFunction {
  public SObject apply(SObject record) {
    Account acc = (Account) record;

    if (
      acc.Verified_by_Data_Steward__c == 'Verified' ||
      acc.Verified_by_Data_Steward__c == 'Owner\'s input requested'
    ) {
      acc.Assigned_Data_Steward__c = UserInfo.getUserId();
    }

    return acc;
  }

  /**
   * On Account Insert, Populate Assigned Data Steward field with current user when Data Steward is checked
   */
  public static void deriveDataStewardUserOnInsert(List<Account> records) {
    Collection.of(records).mapAll(new AccountSetDataStewardFunction());
  }

  /**
   * On Account Update, Populate Assigned Data Steward field with current user when Data Steward is checked
   */
  public static void deriveDataStewardUserOnUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasStewardshipFlagChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.Verified_by_Data_Steward__c },
      accounts,
      existingAccounts
    );

    Collection.of(accounts).filter(hasStewardshipFlagChanged).mapAll(new AccountSetDataStewardFunction());
  }
}
