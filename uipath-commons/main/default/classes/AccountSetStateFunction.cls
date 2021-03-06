/**
 * Sets State on each Account. Takes value from Billing_State_Text_D_B__c
 */
public class AccountSetStateFunction implements SObjectToSObjectFunction {
  public AccountSetStateFunction() {
  }

  public SObject apply(Account acc) {
    if (
      (acc.BillingCountryCode == 'US' ||
      acc.BillingCountryCode == 'CN' ||
      acc.BillingCountryCode == 'AU' ||
      acc.BillingCountryCode == 'BR' ||
      acc.BillingCountryCode == 'CA' ||
      acc.BillingCountryCode == 'GB' ||
      acc.BillingCountryCode == 'IE' ||
      acc.BillingCountryCode == 'IN' ||
      acc.BillingCountryCode == 'IT' ||
      acc.BillingCountryCode == 'MX') && String.isNotBlank(acc.Billing_State_Text_D_B__c)
    ) {
      acc.BillingState = acc.Billing_State_Text_D_B__c;
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  /**
   * Inserts BillingState if Billing_State_Text_D_B__cis changed
   * or if Country is changed and is one of the following: United States, China, Australia, Brazil, Canada, United Kingdom, Ireland, India, Italy, Mexico
   */
  public static void deriveStateOnInsert(List<Account> records) {
    Collection.of(records)
      .mapSome(
        Match.field(Account.BillingState)
          .equals(null)
          .also(Account.Billing_State_Text_D_B__c)
          .hasValue()
          .also(Account.BillingCountry)
          .hasValue(),
        new AccountSetStateFunction()
      );
  }

  /**
   * Updates BillingState if Billing_State_Text_D_B__c is changed
   */
  public static void deriveStateOnUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasDBStateChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.Billing_State_Text_D_B__c },
      accounts,
      existingAccounts
    );

    Collection.of(accounts).filter(hasDBStateChanged).mapAll(new AccountSetStateFunction());
  }
}
