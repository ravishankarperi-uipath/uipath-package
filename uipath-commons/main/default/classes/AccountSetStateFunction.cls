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
      acc.BillingCountryCode == 'MX') &&
      String.isNotBlank(acc.Billing_State_Text_D_B__c)
    ) {
      acc.BillingState = acc.Billing_State_Text_D_B__c;
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }
}
