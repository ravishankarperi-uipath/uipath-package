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
      DNBoptimizer__SIC4Code1__c = '1243',
      DNBoptimizer__SIC4Code1Description__c = 'This is just the description',
      DNBoptimizer__SalesVolumeUSDollars__c = 150000000.00,
      DNBoptimizer__Fortune1000Rank__c = '2',
      DNBoptimizer__WebAddress__c = 'www.testwebsite.com'
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
      Overwrite_Annual_Revenue__c = false,
      Overwrite_Legal_Entity_Name__c = false
    );
    insert account1;

    AccountDnBSyncQueueable accSetAnnualRevenueQueueable = new AccountDnBSyncQueueable(new List<SObject>{ account1 });
    accSetAnnualRevenueQueueable.execute(null);

    List<Account> updatedAccount = [
      SELECT Id, AnnualRevenue, Legal__c, SIC4_Code_1_Description__c, SIC4_Code_1__c, Fortune_1000_Rank__c, Website
      FROM Account
      WHERE Id = :account1.Id
      LIMIT 1
    ];

    System.assertEquals(150000000.00, updatedAccount[0].AnnualRevenue);
    System.assertEquals('DnBTest1', updatedAccount[0].Legal__c);
    System.assertEquals('This is just the description', updatedAccount[0].SIC4_Code_1_Description__c);
    System.assertEquals('1243', updatedAccount[0].SIC4_Code_1__c);
    System.assertEquals('2', updatedAccount[0].Fortune_1000_Rank__c);
    System.assertEquals('www.testwebsite.com', updatedAccount[0].Website);
  }
}
