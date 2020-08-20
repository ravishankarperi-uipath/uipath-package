/**
 * Sets recordType on each account. Uses Account_Business_Type__c to determine recordType
 */
public class AccountSetRecordTypeFunction implements SObjectToSObjectFunction {
  private Id partnerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Partner_Prospect')
    .getRecordTypeId();
  private Id customerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Customer_Prospect')
    .getRecordTypeId();

  public AccountSetRecordTypeFunction() {
  }

  public SObject apply(Account acc) {
    if (acc.Account_Business_Type__c == 'Partner') {
      acc.RecordTypeId = partnerProspectRT;
    } else if (acc.Account_Business_Type__c == 'Customer') {
      acc.RecordTypeId = customerProspectRT;
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  /**
   * Sets Record Type based on Account Business Type
   * If Partner, sets record type to Partner Prospect
   * If Customer, setts record Type to Customer Prospect
   */
  public static void deriveRecordTypeOnInsert(List<Account> records) {
    Collection.of(records)
      .mapSome(Match.field(Account.Account_Business_Type__c).hasValue(), new AccountSetRecordTypeFunction());
  }

  /**
   * Updates record type based on Account Business Type
   */
  public static void deriveRecordTypeForExistingAccount(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasBusinessTypeChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.Account_Business_Type__c },
      accounts,
      existingAccounts
    );

    Collection.of(accounts).filter(hasBusinessTypeChanged).mapAll(new AccountSetRecordTypeFunction());
  }
}
