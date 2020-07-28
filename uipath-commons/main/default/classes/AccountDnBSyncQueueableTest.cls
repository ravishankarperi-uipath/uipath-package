/**
 * TODO REWRITE with fflib Mocking
 */
@isTest
private class AccountDnBSyncQueueableTest {
  @isTest
  private static void setDnBSyncQueueableTest() {
    DNBoptimizer__DnBCompanyRecord__c dnbCompanyRecord = new DNBoptimizer__DnBCompanyRecord__c(
      DNBoptimizer__BusinessName__c = 'DnBTest1',
      Name = '1234',
      DNBoptimizer__SalesVolumeUSDollars__c = 150000000.00
    );

    insert dnbCompanyRecord;

    Account account1 = new Account(
      Name = 'Test1',
      BillingCountry = 'China',
      Industry = 'Apparel',
      Revenue_Source__c = null,
      Legal__c = null,
      DNBoptimizer__DnBCompanyRecord__c = dnbCompanyRecord.Id,
      AnnualRevenue = null,
      Overwrite_Annual_Revenue__c = false
    );
    insert account1;

    AccountDnBSyncQueueable accSetAnnualRevenueQueueable = new AccountDnBSyncQueueable(
      new List<SObject>{ account1 }
    );
    accSetAnnualRevenueQueueable.execute(null);

    List<Account> updatedAccount = [
      SELECT Id, AnnualRevenue
      FROM Account
      WHERE Id = :account1.Id
      LIMIT 1
    ];

    System.assertEquals(150000000.00, updatedAccount[0].AnnualRevenue);
  }
}
