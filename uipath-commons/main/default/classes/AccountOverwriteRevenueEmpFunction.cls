/**
 * Sets AnnualRevenue and NumberOfEmployees to values in DNBoptimizer__DnBCompanyRecord__c
 * if Overwrite_Annual_Revenue__c = false or Overwrite_Employee_Number__c = false
 * else the user can overwrite the values
 */
public with sharing class AccountOverwriteRevenueEmpFunction implements SObjectToSObjectFunction {
  private Map<Id, DNBoptimizer__DnBCompanyRecord__c> relatedDnBOptimizerMap;

  public AccountOverwriteRevenueEmpFunction(List<Account> accounts) {
    Set<Id> dnbIds = new Set<Id>();
    for (Account acc : accounts)
      if (acc.DNBoptimizer__DnBCompanyRecord__c != null)
        dnbIds.add(acc.DNBoptimizer__DnBCompanyRecord__c);
    relatedDnBOptimizerMap = new Map<Id, DNBoptimizer__DnBCompanyRecord__c>(
      [
        SELECT Id, DNBoptimizer__SalesVolumeUSDollars__c, DNBoptimizer__EmployeeCountTotal__c
        FROM DNBoptimizer__DnBCompanyRecord__c
        WHERE Id IN :dnbIds
      ]
    );
  }

  public SObject apply(Account acc) {
    if (acc.DNBoptimizer__DnBCompanyRecord__c != null) {
      if (
        acc.Overwrite_Annual_Revenue__c == false &&
        relatedDnBOptimizerMap.containsKey(acc.DNBoptimizer__DnBCompanyRecord__c)
      ) {
        acc.AnnualRevenue = relatedDnBOptimizerMap.get(acc.DNBoptimizer__DnBCompanyRecord__c)
          .DNBoptimizer__SalesVolumeUSDollars__c;
      }
      if (
        acc.Overwrite_Employee_Number__c == false &&
        relatedDnBOptimizerMap.containsKey(acc.DNBoptimizer__DnBCompanyRecord__c)
      ) {
        acc.NumberOfEmployees = Integer.valueOf(
          relatedDnBOptimizerMap.get(acc.DNBoptimizer__DnBCompanyRecord__c).DNBoptimizer__EmployeeCountTotal__c
        );
      }
    } else {
      if (acc.Overwrite_Annual_Revenue__c == false)
        acc.AnnualRevenue = null;
      if (acc.Overwrite_Employee_Number__c == false)
        acc.NumberOfEmployees = null;
    }

    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  public static void deriveRecordTypeOnUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.AnnualRevenue,
        Account.NumberOfEmployees,
        Account.Overwrite_Annual_Revenue__c,
        Account.Overwrite_Employee_Number__c
      },
      accounts,
      existingAccounts
    );

    List<Account> changedAccounts = Collection.of(accounts).filter(hasChanged).asList();

    if (!changedAccounts.isEmpty()) {
      Collection.of(changedAccounts).mapAll(new AccountOverwriteRevenueEmpFunction(changedAccounts));
    }
  }
}
