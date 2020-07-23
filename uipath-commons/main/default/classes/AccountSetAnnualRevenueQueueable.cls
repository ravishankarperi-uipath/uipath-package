public with sharing class AccountSetAnnualRevenueQueueable extends AbstractQueueable {
  /**
   * Set Revenue Source field on Account
   * If Account AnnualRevenue is equal to DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c populates Revenue Source with Dun & Bradstreet
   */

  private final List<SObject> accountsLst;

  public AccountSetAnnualRevenueQueueable(List<SObject> accountsLst) {
    super('AccountSetAnnualRevenueQueueable');
    this.accountsLst = accountsLst;
  }

  public override void work() {
    this.setAnnualRevenue(this.accountsLst);
  }

  private void setAnnualRevenue(List<SObject> accountsLst) {
    List<Account> accounts = (List<Account>) accountsLst;
    accounts = [
      SELECT
        Id,
        AnnualRevenue,
        DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c
      FROM Account
      WHERE Id IN :accounts 
      AND DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c != NULL
    ];

    if (!accounts.isEmpty()) {
      for (Account acc : accounts) {
          acc.AnnualRevenue = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c;
          acc.Revenue_Source__c = 'Dun & Bradstreet';
      }
      update accounts;
    }
  }
}
