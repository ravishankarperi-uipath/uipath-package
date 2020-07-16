/**
 * TODO REWRITE : Can be moved to contact before trigger
 * Update contact LeadSource for all Japan converted Leads
 * *Org-cleanup : Process Builder - Conversion aid, Geo and Region
 */
public with sharing class AccountUpdateJapanContactQueueable extends AbstractQueueable {
  private final List<SObject> accountList;

  public AccountUpdateJapanContactQueueable(List<SObject> accountList) {
    super('AccountUpdateJapanContactQueueable');
    this.accountList = accountList;
  }

  public override void work() {
    this.setLeadSourceOnContact(this.accountList);
  }

  private void setLeadSourceOnContact(List<Account> accountList) {
    Set<Id> accIds = new Set<Id>();

    for (Account acc : accountList) {
      if (acc.Country__c == 'Japan' && acc.Created_by_lead_convert__c) {
        accIds.add(acc.Id);
      }
    }

    if (!accIds.isEmpty()) {
      List<Contact> conList = [
        SELECT Id, LeadSource
        FROM Contact
        WHERE AccountId IN :accIds
      ];
      for (Contact con : conList) {
        con.LeadSource = 'Partner';
      }

      if (!conList.isEmpty()) {
        update conList;
      }
    }
  }
}
