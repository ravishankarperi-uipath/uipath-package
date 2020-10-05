@isTest
private class AccountOverwriteRevenueEmpFunctionTest {
  @isTest
  private static void setEmployeeAnualRevenueTest1() {
    Id prospectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();

    DNBoptimizer__DnBCompanyRecord__c dnbopt = new DNBoptimizer__DnBCompanyRecord__c(
      Name = 'Test',
      DNBoptimizer__SalesVolumeUSDollars__c = 20000000.00,
      DNBoptimizer__EmployeeCountTotal__c = 19
    );
    insert dnbopt;

    Account account1 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test1',
      Geo__c = 'APAC',
      RecordTypeId = prospectRT,
      AnnualRevenue = 150000000.00,
      NumberOfEmployees = 12,
      Overwrite_Annual_Revenue__c = false,
      Overwrite_Employee_Number__c = false,
      DNBoptimizer__DnBCompanyRecord__c = dnbopt.Id
    );
    Account oldAccount1 = new Account(Id = account1.Id, Name = 'Test1', DNBoptimizer__DnBCompanyRecord__c = dnbopt.Id);

    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Account>{ account1 },
      new Map<Id, SObject>{ oldAccount1.Id => oldAccount1 }
    );
    fflib_SObjectDomain.triggerHandler(Accounts.class);

    System.assertEquals(20000000.00, account1.AnnualRevenue);
    System.assertEquals(19, account1.NumberOfEmployees);
  }

  @isTest
  private static void setEmployeeAnualRevenueTest2() {
    Id prospectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();

    Account account1 = new Account(
      Id = fflib_IDGenerator.generate(Account.SObjectType),
      Name = 'Test1',
      Geo__c = 'APAC',
      RecordTypeId = prospectRT,
      AnnualRevenue = 100000000.00,
      NumberOfEmployees = 10,
      Overwrite_Annual_Revenue__c = false,
      Overwrite_Employee_Number__c = false
    );
    Account oldAccount1 = new Account(
      Id = account1.Id,
      Name = 'Test1',
      AnnualRevenue = 150000000.00,
      NumberOfEmployees = 12,
      Overwrite_Annual_Revenue__c = true,
      Overwrite_Employee_Number__c = true
    );

    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Account>{ account1 },
      new Map<Id, SObject>{ oldAccount1.Id => oldAccount1 }
    );
    fflib_SObjectDomain.triggerHandler(Accounts.class);

    System.assertEquals(account1.AnnualRevenue, null);
    System.assertEquals(account1.NumberOfEmployees, null);
  }
}
