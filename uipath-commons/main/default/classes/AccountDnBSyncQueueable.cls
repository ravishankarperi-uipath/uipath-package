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

  /**
   * Copies fields from DNBoptimizer__DnBCompanyRecord__c when the lookup on account is updated
   * @param accountsLst
   */
  private void setDnBFields(List<SObject> accountsLst) {
    List<Account> accounts = reQueryAccountsWithRelevantFields(accountsLst);

    if (!accounts.isEmpty()) {
      for (Account acc : accounts) {
        if (acc.Overwrite_Annual_Revenue__c == false) {
          acc.AnnualRevenue = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SalesVolumeUSDollars__c;
          acc.Revenue_Source__c = DNB;
        }

        if (acc.Overwrite_Legal_Entity_Name__c == false) {
          acc.Legal__c = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__BusinessName__c;
        }

        acc.SIC4_Code_1__c = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1__c;

        acc.SIC4_Code_1_Description__c = acc.DNBoptimizer__DnBCompanyRecord__r.DNBoptimizer__SIC4Code1Description__c;
      }
      update accounts;
    }
  }

  private List<Account> reQueryAccountsWithRelevantFields(
    List<SObject> accountsLst
  ) {
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
    return accounts;
  }

  /**
   * On Account Insert, sync Account fields with DnB fields
   */
  public static void deriveDnBFieldsOnInsert(List<Account> records) {
    List<Account> validatedAccounts = Collection.of(records)
      .filter(Match.field(Account.DNBoptimizer__DnBCompanyRecord__c).hasValue())
      .asList();

    if (!validatedAccounts.isEmpty()) {
      AbstractQueueable.enqueue(new AccountDnBSyncQueueable(validatedAccounts));
    }
  }

  /**
   * On Account Update, sync Account with DnB
   **/
  public static void deriveDnBFieldsOnUpdate(
    List<Account> accounts,
    Map<Id, SObject> existingAccounts
  ) {
    SObjectPredicate hasDnBObjectChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.DNBoptimizer__DnBCompanyRecord__c },
      accounts,
      existingAccounts
    );

    List<Account> validatedAccounts = Collection.of(accounts)
      .filter(hasDnBObjectChanged)
      .asList();

    if (!validatedAccounts.isEmpty()) {
      AbstractQueueable.enqueue(new AccountDnBSyncQueueable(validatedAccounts));
    }
  }
}
