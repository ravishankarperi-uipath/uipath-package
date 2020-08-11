/**
 * Set Billing State to the same value as the Custom State field when new Accounts are created
 */
public with sharing class AccountBillingStateFromStateFunction implements SObjectToSObjectFunction {
  public SObject apply(Account acc) {
    Map<String, String> stateNameAndCodeMap = AccountMetadata.StateNameAndCodes;
    if ((acc.State__c != null)) {
      acc.BillingState = acc.State__c;
      acc.BillingStateCode = StateNameAndCodeMap.get(acc.State__c);
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  /**
   * On Account Insert, Populate Assigned Data Steward field with current user when Data Steward is checked
   */
  public static void copyStateToBillingState(List<Account> records) {
    Collection.of(records).mapAll(new AccountBillingStateFromStateFunction());
  }
}
