/**
 * Sets fields Geo and Region to ‘Japan’ for Japanese Accounts created via Lead conversion.
 * “Japanese accounts” are when  Country=Japan
 */
public with sharing class AccountJapanConvertedLeadFunction implements SObjectToSObjectFunction {
  public SObject apply(Account acc) {
    if (acc.Country__c == 'Japan' && acc.Created_by_lead_convert__c) {
      acc.Geo__c = 'Japan';
      acc.Region__c = 'Japan';
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  /**
   * On Account Insert, Populate Assigned Data Steward field with current user when Data Steward is checked
   */
  public static void setGeoFields(List<Account> records) {
    Collection.of(records).mapAll(new AccountJapanConvertedLeadFunction());
  }
}
