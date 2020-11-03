/**
 */
public with sharing class SalesCaseBillToWOppQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private static Boolean isAlreadyRun = false;

  public SalesCaseBillToWOppQueueable(List<SObject> cases) {
    super('SalesCaseBillToWOppQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.updateBillTo(this.cases);
  }

  private void updateBillTo(List<Case> cases) {
    List<Case> casesToUpdate = [SELECT AccountId, Opportunity__r.Sold_to_Partner__c FROM Case WHERE Id IN :cases];

    for (Case caseRecord : casesToUpdate) {
      if (caseRecord.Opportunity__r.Sold_to_Partner__c != null) {
        caseRecord.Bill_To__c = caseRecord.Opportunity__r.Sold_to_Partner__c;
      } else {
        caseRecord.Bill_To__c = caseRecord.AccountId;
      }
    }

    if (!casesToUpdate.isEmpty()) {
      update casesToUpdate;
    }
  }

  public static void updateBillToOnUpdate(List<Case> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.AccountId, Case.Opportunity__c },
      cases,
      existingCases
    );

    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              SalesCaseMetadata.LegalRequestRecordType,
              SalesCaseMetadata.UiPathJapanPartnerStandardRecordType
            }
          )
          .also(Case.Opportunity__c)
          .notEquals(null)
      )
      .filter(Match.field(Case.isClosed).equals(false))
      .asList();

    if (!eligibleCases.isEmpty()) {
      if (!isAlreadyRun) {
        isAlreadyRun = true;
        AbstractQueueable.enqueue(new SalesCaseBillToWOppQueueable(eligibleCases));
      }
    }
  }

  public static void updateBillToOnInsert(List<Case> cases) {
    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              SalesCaseMetadata.LegalRequestRecordType,
              SalesCaseMetadata.UiPathJapanPartnerStandardRecordType
            }
          )
          .also(Case.Opportunity__c)
          .notEquals(null)
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      if (!isAlreadyRun) {
        isAlreadyRun = true;
        AbstractQueueable.enqueue(new SalesCaseBillToWOppQueueable(eligibleCases));
      }
    }
  }
}
