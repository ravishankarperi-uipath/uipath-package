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

  private void changeAccount(SObject record) {
    if (
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c) !=
      null &&
      record.get(Account.AnnualRevenue) <>
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c) &&
      record.get(Account.Overwrite_Annual_Revenue__c) == false
    ) {
      record.get(Account.AnnualRevenue) = account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c;
      record.get(Account.Revenue_Source__c) = DNB;
    }

    if (
      record.get(Account.Revenue_Source__c) <> DNB &&
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c) ==
      record.get(Account.AnnualRevenue)
    ) {
      record.get(Account.Revenue_Source__c) = DNB;
    }

    if (
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c) !=
      null &&
      record.get(Account.Legal__c) <>
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c) &&
      record.get(Account.Overwrite_Legal_Entity_Name__c) == false
    ) {
      record.get(Account.Legal__c) = record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c);
    }

    if (
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1__c) !=
      null &&
      record.get(Account.SIC4_Code_1__c) <>
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1__c)
    ) {
      record.get(Account.SIC4_Code_1__c) = record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1__c);
    }

    if (
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1Description__c) !=
      null &&
      record.get(Account.SIC4_Code_1_Description__c) <>
      record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1Description__c)
    ) {
      record.get(Account.SIC4_Code_1_Description__c) = record.get(Account.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1Description__c);
    }
  }
}
