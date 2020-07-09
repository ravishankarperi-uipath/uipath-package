
public with sharing class AccountValidationFunction implements SObjectToSObjectFunction {

    private final Map<Id, SObject> existingRecords;
    private final fflib_SObjectDomain domain;

    public AccountValidationFunction(Map<Id, SObject> existingRecords,fflib_SObjectDomain domain) {
        this.existingRecords = existingRecords;
        this.domain=domain;
    }

    public SObject apply(Account modifiedAccount) {


        validateStatePopulatedForChinaAustralia(modifiedAccount);

        //Validate during updates
        if(existingRecords!=null && !existingRecords.isEmpty()){
            validateIfDnBCountryChanged(modifiedAccount);
        }

        return modifiedAccount;
    }

    public SObject apply(SObject record) {
        return apply((Account) record);
    }

    private void validateIfDnBCountryChanged(Account acc) {

        Account oldAcc = (Account) existingRecords.get(acc.Id);

        if (
            String.isNotBlank(acc.DnB_Country__c) &&
                String.isBlank(oldAcc.DnB_Country__c)
            ) {
            if (acc.DnB_Country__c != acc.Country__c) {
                acc.addError(
                    domain.error(
                        'You cannot select a D&B Company from a different country.',
                        acc
                    )
                );
            }
        }
    }

    private void validateStatePopulatedForChinaAustralia(Account acc) {
        if (isCountryChinaOrAustraliaOrIndia(acc) && acc.State__c == null) {
            acc.State__c.addError(
                domain.error(
                    'State is required if Country is ' + acc.Country__c,
                    acc,
                    Account.State__c
                )
            );
        }
    }

    private Boolean isCountryChinaOrAustraliaOrIndia(Account acc) {
        return (acc.Country__c == 'China' || acc.Country__c == 'Australia' || acc.Country__c == 'India');
    }


}