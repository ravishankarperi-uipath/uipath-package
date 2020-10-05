/**
 * Sets State on each Account. Takes value from Billing_State_Text_D_B__c
 */
public class AccountSetStateFunction implements SObjectToSObjectFunction {
  private List<String> AvailableCountryStates;

  public AccountSetStateFunction(List<Account> listAccounts, Map<Id, SObject> existingAccounts) {
    AvailableCountryStates = new List<String>();

    Schema.DescribeFieldResult stateResult = Address__c.State__c.getDescribe();
    List<Schema.PicklistEntry> statePLE = stateResult.getPicklistValues();
    for (Schema.PicklistEntry entry : statePLE) {
      AvailableCountryStates.add(entry.getValue());
    }
  }

  public SObject apply(Account acc) {
    if (
      AvailableCountryStates.Contains(acc.DnB_State_Province__c) &&
      (acc.BillingCountryCode == 'US' ||
      acc.BillingCountryCode == 'CN' ||
      acc.BillingCountryCode == 'AU' ||
      acc.BillingCountryCode == 'BR' ||
      acc.BillingCountryCode == 'CA' ||
      acc.BillingCountryCode == 'GB' ||
      acc.BillingCountryCode == 'IE' ||
      acc.BillingCountryCode == 'IN' ||
      acc.BillingCountryCode == 'IT' ||
      acc.BillingCountryCode == 'MX') &&
      String.isNotBlank(acc.DnB_State_Province__c)
    ) {
      acc.BillingState = acc.DnB_State_Province__c;
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
          .also(Account.DnB_State_Province__c)
          .hasValue()
          .also(Account.BillingCountry)
          .hasValue(),
        new AccountSetStateFunction(records, null)
      );
  }

  /**
   * Updates BillingState if Billing_State_Text_D_B__c is changed
   */
  public static void deriveStateOnUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasDBStateChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.DnB_State_Province__c },
      accounts,
      existingAccounts
    );
    List<Account> changedAccounts = Collection.of(accounts).filter(hasDBStateChanged).asList();
    if (!changedAccounts.isEmpty()) {
      Collection.of(changedAccounts).mapAll(new AccountSetStateFunction(changedAccounts, existingAccounts));
    }
  }
}
