public with sharing class AccountSetRevenueSourceQueueable extends AbstractQueueable {
  /**
   * Set Revenue Source field on Account
   * If Account AnnualRevenue is equal to DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c populates Revenue Source with Dun & Bradstreet
   */

  private final List<SObject> accountsLst;

  public AccountSetRevenueSourceQueueable(List<SObject> accountsLst) {
    super('AccountSetRevenueSourceQueueable');
    this.accountsLst = accountsLst;
  }

  public override void work() {
    this.setRevenueSource(this.accountsLst);
  }

  private void setRevenueSource(List<SObject> accountsLst) {
    List<Account> accounts = (List<Account>) accountsLst;
    accounts = [
      SELECT
        Id,
        AnnualRevenue,
        DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c
      FROM Account
      WHERE Id IN :accounts
    ];

    for (Account acc : accounts) {
      if (
        acc.AnnualRevenue ==
        acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c
      ) {
        acc.Revenue_Source__c = 'Dun & Bradstreet';
      }
    }
    update accounts;
  }
}
