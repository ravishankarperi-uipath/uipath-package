public class HasMetDnBQueueableCriteria implements SObjectPredicate {
  List<SObject> validatedAccounts = new List<SObject>();

  public HasMetDnBQueueableCriteria(List<SObject> records) {
    validatedAccounts.addAll(
      Collection.of(records)
        .filter(
          Match.field(Account.AnnualRevenue)
            .equals(null)
            .also(Account.DNBoptimizer__DnBCompanyRecord__c)
            .hasValue()
            .also(Account.Overwrite_Annual_Revenue__c)
            .equals(false)
        )
        .asList()
    );

    validatedAccounts.addAll(
      Collection.of(records)
        .filter(
          Match.field(Account.Revenue_Source__c)
            .equals(null)
            .also(Account.DNBoptimizer__DnBCompanyRecord__c)
            .hasValue()
        )
        .asList()
    );

    validatedAccounts.addAll(
      Collection.of(records)
        .filter(
          Match.field(Account.Legal__c)
            .equals(null)
            .also(Account.DNBoptimizer__DnBCompanyRecord__c)
            .hasValue()
            .also(Account.Overwrite_Legal_Entity_Name__c)
            .equals(false)
        )
        .asList()
    );
  }

  public Boolean apply(SObject record) {
    return !validatedAccounts.isEmpty();
  }
}
