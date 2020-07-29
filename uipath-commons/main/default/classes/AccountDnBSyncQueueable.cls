public with sharing class AccountDnBSyncQueueable extends AbstractQueueable {
  /**
   * Set Revenue Source field on Account
   * If Account AnnualRevenue is equal to DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c populates Revenue Source with Dun & Bradstreet
   */

  private final List<SObject> accountsLst;
  static final String DNB = 'Dun & Bradstreet';

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
        SIC4_Code_1__c,
        SIC4_Code_1_Description__c,
        DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1Description__c,
        DNBoptimizer__DnBCompanyRecord__c,
        DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1__c,
        Legal__c,
        DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c,
        DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c
      FROM Account
      WHERE Id IN :accounts AND DNBoptimizer__DnBCompanyRecord__c != null
    ];

    if (!accounts.isEmpty()) {
      for (Account acc : accounts) {
        changeAccount(acc);
      }
      update accounts;
    }
  }

  private void changeAccount(SObject account) {
    if (
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c !=
      null &&
      account.AnnualRevenue <>
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c &&
      account.Overwrite_Annual_Revenue__c == false
    ) {
      account.AnnualRevenue = account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c;
      account.Revenue_Source__c = DNB;
    }

    if (
      account.Revenue_Source__c <> DNB &&
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c ==
      account.AnnualRevenue
    ) {
      account.Revenue_Source__c = DNB;
    }

    if (
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c !=
      null &&
      account.Legal__c <>
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c &&
      account.Overwrite_Legal_Entity_Name__c == false
    ) {
      account.Legal__c = account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c;
    }

    if (
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1__c !=
      null &&
      account.SIC4_Code_1__c <>
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1__c
    ) {
      account.SIC4_Code_1__c = account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1__c;
    }

    if (
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1Description__c !=
      null &&
      account.SIC4_Code_1_Description__c <>
      account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1Description__c
    ) {
      account.SIC4_Code_1_Description__c = account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1Description__c;
    }
  }
}
