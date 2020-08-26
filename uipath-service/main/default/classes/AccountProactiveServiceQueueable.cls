/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates the Proactive Request service count
 */
public with sharing class AccountProactiveServiceQueueable extends AbstractQueueable {
  private final List<SObject> cases;

  public AccountProactiveServiceQueueable(List<SObject> cases) {
    super('AccountProactiveServiceQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.validateAndUpdateCounter(this.cases);
  }

  private void validateAndUpdateCounter(List<SObject> cases) {
    User newUser = [
      SELECT
        Id,
        ContactId,
        Account.of_Proactive_services__c,
        Account.Max_of_Services_Quarter__c,
        Account.requests_this_quarter__c,
        AccountId
      FROM User
      WHERE Id = :Userinfo.getUserId()
    ];

    if (newUser.ContactId == null) {
      return;
    }

    List<Account> accountsToUpdate = new List<Account>();
    for (Case newCase : (List<Case>) cases) {
      if (newCase.RecordtypeId != CaseMetadata.ProactiveCareRecordType) {
        continue;
      }
      if (nullAsZero(newUser.Account.requests_this_quarter__c) >= newUser.Account.Max_of_Services_Quarter__c) {
        throw new DMLException(
          'You cannot create a Proactive Service for this quarter as you have already availed the new case for this quarter.'
        );
      }
      Account account = new Account();
      account.Id = newUser.AccountId;
      account.of_Proactive_services__c = nullAsZero(newUser.Account.of_Proactive_services__c) + 5;
      account.requests_this_quarter__c = nullAsZero(newUser.Account.requests_this_quarter__c) + 1;
      accountsToUpdate.add(account);
    }
    if (!accountsToUpdate.isEmpty()) {
      update accountsToUpdate;
    }
  }

  private static Decimal nullAsZero(Decimal value) {
    return (value == null) ? 0 : value;
  }
}
