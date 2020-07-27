public with sharing class AccountDnBSyncQueueable extends AbstractQueueable {
  /**
   * Set Revenue Source field on Account
   * If Account AnnualRevenue is equal to DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c populates Revenue Source with Dun & Bradstreet
   */

  public virtual class HasMetDnBQueueableCriteria implements SObjectPredicate {
    List<SObject> validatedAccounts = new List<SObject>();
  
    public HasMetDnBQueueableCriteria(List<SObject> records) {
      validatedAccounts.addAll(
        Collection.of(records)
          .filter(
            Match.field(Account.AnnualRevenue)
              .equals(null)
              .also(Account.DNBoptimizer__DnBCompanyRecord__c)
              .hasValue()
              .also(Account.Overwrite_Annual_Revenue__c)
              .equals(false)
          )
          .asList()
      );
  
      validatedAccounts.addAll(
        Collection.of(records)
          .filter(
            Match.field(Account.Revenue_Source__c)
              .equals(null)
              .also(Account.DNBoptimizer__DnBCompanyRecord__c)
              .hasValue()
          )
          .asList()
      );
  
      validatedAccounts.addAll(
        Collection.of(records)
          .filter(
            Match.field(Account.Legal__c)
              .equals(null)
              .also(Account.DNBoptimizer__DnBCompanyRecord__c)
              .hasValue()
              .also(Account.Overwrite_Legal_Entity_Name__c)
              .equals(false)
          )
          .asList()
      );
    }
  
    public Boolean apply(SObject record) {
      return !validatedAccounts.isEmpty();
    }
  }  

  private final List<SObject> accountsLst;

  public AccountDnBSyncQueueable(List<SObject> accountsLst) {
    super('AccountDnBSyncQueueable');
    this.accountsLst = accountsLst;
  }

  public override void work() {
    this.setDnBFields(this.accountsLst);
  }

  private void setDnBFields(List<SObject> accountsLst) {
    List<Account> accounts = (List<Account>) accountsLst;
    accounts = [
      SELECT
        Id,
        Overwrite_Annual_Revenue__c,
        Overwrite_Legal_Entity_Name__c,
        Revenue_Source__c,
        AnnualRevenue,
        Legal__c,
        DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c,
        DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c
      FROM Account
      WHERE Id IN :accounts AND DNBoptimizer__DnBCompanyRecord__c != null
    ];

    if (!accounts.isEmpty()) {
      for (Account acc : accounts) {
        if (
          acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c !=
          null &&
          acc.AnnualRevenue == null &&
          acc.Overwrite_Annual_Revenue__c == false
        ) {
          acc.AnnualRevenue = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c;
          acc.Revenue_Source__c = 'Dun & Bradstreet';
        }

        if (
          acc.Revenue_Source__c == null &&
          acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c ==
          acc.AnnualRevenue
        ) {
          acc.Revenue_Source__c = 'Dun & Bradstreet';
        }

        if (
          acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c !=
          null &&
          acc.Legal__c == null &&
          acc.Overwrite_Legal_Entity_Name__c == false
        ) {
          acc.Legal__c = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c;
        }
      }
      update accounts;
    }
  }
}
