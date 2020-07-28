/**
 * Sets State on each Account. Takes value from Billing_State_Text_D_B__c
 */
public class AccountSetStateFunction implements SObjectToSObjectFunction {
  public AccountSetStateFunction() {
  }

  public SObject apply(Account acc) {
    if (
      acc.BillingCountry == 'United States' ||
      acc.BillingCountry == 'China' ||
      acc.BillingCountry == 'Australia' ||
      acc.BillingCountry == 'Brazil' ||
      acc.BillingCountry == 'Canada' ||
      acc.BillingCountry == 'United Kingdom' ||
      acc.BillingCountry == 'Ireland' ||
      acc.BillingCountry == 'India' ||
      acc.BillingCountry == 'Italy' ||
      acc.BillingCountry == 'Mexico'
    ) {
      acc.BillingState = acc.Billing_State_Text_D_B__c;
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }
}
