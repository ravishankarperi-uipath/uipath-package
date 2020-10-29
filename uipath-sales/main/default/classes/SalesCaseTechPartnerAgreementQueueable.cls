/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates Account on Signed/Declined Legal Document
 */
public with sharing class SalesCaseTechPartnerAgreementQueueable extends AbstractQueueable {
  private final List<SObject> cases;

  public SalesCaseTechPartnerAgreementQueueable(List<SObject> cases) {
    super('SalesCaseTechPartnerAgreementQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.updateAccounts(this.cases);
  }

  private void updateAccounts(List<Case> cases) {
    List<Account> accountsToUpdate = new List<Account>();
    for (Case caseRecord : cases) {
      Account accountRecord = new Account(Id = caseRecord.AccountId);
      if (caseRecord.Status == SalesCaseMetadata.SIGNED) {
        accountRecord.Allbound_Status__c = 'Active';
        accountRecord.Technology_Partner_Level__c = 'Registered';
        accountRecord.Technology_Partnership_signed_Date__c = System.today();
      } else {
        accountRecord.Technology_Partnership_Deny_Date__c = System.today();
      }
      accountsToUpdate.add(accountRecord);
    }

    if (!accountsToUpdate.isEmpty()) {
      update accountsToUpdate;
    }
  }

  public static void deriveTechPartnershipDateOnAccount(List<Case> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Document_Type__c, Case.Status, Case.RecordTypeId },
      cases,
      existingCases
    );

    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(new Set<String>{ SalesCaseMetadata.LegalProductRequestRecordType })
          .also(Case.Document_Type__c)
          .equals(SalesCaseMetadata.TECHNOLOGY_ALLIANCE_AGREEMENT)
      )
      .filter(
        Match.field(Case.Status)
          .isIn(new Set<String>{ SalesCaseMetadata.SIGNED, SalesCaseMetadata.NOT_SIGNED })
          .also(Case.AccountId)
          .hasValue()
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      AbstractQueueable.enqueue(new SalesCaseTechPartnerAgreementQueueable(eligibleCases));
    }
  }
}
