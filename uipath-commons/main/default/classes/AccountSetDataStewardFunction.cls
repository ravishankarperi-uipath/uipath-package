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
}
