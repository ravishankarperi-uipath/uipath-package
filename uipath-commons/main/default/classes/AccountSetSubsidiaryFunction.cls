/**
 * Sets subsidiary on each account. Uses Country__c to determine subsidiart
 */
public class AccountSetSubsidiaryFunction implements SObjectToSObjectFunction {
  private Map<String, String> countrySubsidiaryMap;

  public AccountSetSubsidiaryFunction(
    Map<String, String> countrySubsidiaryMap
  ) {
    this.countrySubsidiaryMap = countrySubsidiaryMap;
  }

  public SObject apply(Account acc) {
    //take the first 40 characters as the label field has a max 40 chars
    String accountCountryToFind = acc.Country__c.left(40).toLowerCase();
    String countrySubsidiary = countrySubsidiaryMap.get(accountCountryToFind);
    if (String.IsNotBlank(countrySubsidiary)) {
      acc.Primary_Subsidiary__c = countrySubsidiaryMap.get(
        accountCountryToFind
      );
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }
}
