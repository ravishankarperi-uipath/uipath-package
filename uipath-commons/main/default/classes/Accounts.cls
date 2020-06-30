public with sharing class Accounts extends fflib_SObjectDomain implements IAccounts {
  public static IAccounts newInstance(List<Account> recordList) {
    return (IAccounts) Application.Domain.newInstance(recordList);
  }

  public static IAccounts newInstance(Set<Id> recordIdSet) {
    return (IAccounts) Application.Domain.newInstance(recordIdSet);
  }

  public Accounts(List<Account> sObjectList) {
    super(sObjectList);
  }

  public override void onBeforeInsert() {
    setBillingStateWhenCountryNotChinaAustralia();
  }

  public override void onAfterInsert() {
    QueueableWrapper.enqueue(
      new AccountSharingRollupQueueable(Records, null)
    );
    QueueableWrapper.enqueue(
      new AccountAddressQueueable(Records, null)
    );
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    QueueableWrapper.enqueue(
      new AccountSharingRollupQueueable(Records, existingRecords)
    );
    QueueableWrapper.enqueue(
      new AccountDNBCompanyQueueable(Records, existingRecords)
    );
    QueueableWrapper.enqueue(
      new AccountSetContactOwnerQueueable(Records, existingRecords)
    );
  }

  public void updateOpportunityActivity(fflib_SObjectUnitOfWork uow) {
    for (Account acc : (List<Account>) Records) {
      acc.Description = 'Last Opportunity Raised ' + System.today();
      uow.registerDirty(acc);
    }
  }

  public void setBillingStateWhenCountryNotChinaAustralia() {
    for (Account account : (List<Account>) Records) {
      if (!isCountryChinaOrAustralia(account) && (account.State__c != null)) {
        account.BillingState = account.State__c;
      }
    }
  }

  public override void onValidate() {
    for (Account acc : (List<Account>) Records) {
      if (isCountryChinaOrAustralia(acc) && acc.State__c == null) {
        acc.State__c.addError(
          error(
            'State is required if Country is ' + acc.Country__c,
            acc,
            Account.State__c
          )
        );
      }
    }
  }

  private Boolean isCountryChinaOrAustralia(Account acc) {
    return (acc.Country__c == 'China' || acc.Country__c == 'Australia');
  }

  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new Accounts(sObjectList);
    }
  }

}
