/**
 * TODO REWRITE with fflib Mocking
 */
@isTest
private class AccountSetAnnualRevenueQueueableTest {
  @isTest
  private static void setAnnualRevenueQueueableTest() {

    DNBoptimizer__DnBCompanyRecord__c DnBCompanyRecord = new DNBoptimizer__DnBCompanyRecord__c(
      DNBoptimizer__BusinessName__c = 'DnBTest1',
      Name = '1234',
      DNBoptimizer__SalesVolumeUSDollars__c = 150000000.00
    );

    insert DnBCompanyRecord;

    Account account1 = new Account(
      Name = 'Test1',
      BillingCountry = 'China',
      Industry = 'Apparel',
      DNBoptimizer__DnBCompanyRecord__c = DnBCompanyRecord.Id,
      AnnualRevenue = null,
      Overwrite_Annual_Revenue__c = false
    );
    insert account1;

    AccountSetAnnualRevenueQueueable accSetAnnualRevenueQueueable = new AccountSetAnnualRevenueQueueable(
      new List<Account>{ account1 }
    );
    accSetAnnualRevenueQueueable.execute(null);

    List<Account> updatedAccount = [
      SELECT Id, AnnualRevenue
      FROM Account
      WHERE Id =: account1.Id
      LIMIT 1
    ];

    System.assertEquals(150000000.00, updatedAccount[0].AnnualRevenue);
  }
}
