/**
 * for Lead conversion, copies BillingCountry to Country
 */
public class AccountCopyCountryFunction implements SObjectToSObjectFunction {
  public AccountCopyCountryFunction() {
  }

  public SObject apply(Account acc) {
    acc.Country__c = acc.BillingCountry;
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  /**
   * copies BillingCountry to Country if it is not already populated
   */
  public static void copyCountryOnInsert(List<Account> records) {
    Collection.of(records)
      .mapSome(
        Match.field(Account.Country__c).equals(null).also(Account.BillingCountry).hasValue(),
        new AccountCopyCountryFunction()
      );
  }
}
