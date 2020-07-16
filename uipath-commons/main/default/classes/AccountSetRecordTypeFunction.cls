/**
 * Sets recordType on each account. Uses Account_Business_Type__c to determine recordType
 */
public class AccountSetRecordTypeFunction implements SObjectToSObjectFunction {
  private Id partnerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Partner_Prospect')
    .getRecordTypeId();
  private Id customerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Customer_Prospect')
    .getRecordTypeId();

  public AccountSetRecordTypeFunction() {
  }

  public SObject apply(Account acc) {
    if (acc.Account_Business_Type__c == 'Partner') {
      acc.RecordTypeId = partnerProspectRT;
    } else if (acc.Account_Business_Type__c == 'Customer') {
      acc.RecordTypeId = customerProspectRT;
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }
}
