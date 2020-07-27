/**
 * Sets State on each Account. Takes value from Billing_State_Text_D_B__c
 */
public class AccountSetStateFunction implements SObjectToSObjectFunction {
  
    public AccountSetStateFunction() {
    }
  
    public SObject apply(Account acc) {
      acc.BillingState = acc.Billing_State_Text_D_B__c;
      return acc;
    }
  
    public SObject apply(SObject record) {
      return apply((Account) record);
    }
  }
  