/**
 * Creates Child Case when the parent Case is Closed and CSAT > 2
 */
public with sharing class CaseCreateChildCaseQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private static Boolean isAlreadyRun = false;

  public CaseCreateChildCaseQueueable(List<SObject> cases) {
    super('CaseCreateChildCaseQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.createChildCase(this.cases);
  }

  private void createChildCase(List<Case> cases) {
    List<Case> children = new List<Case>();

    Group productSuportQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND NAME = 'Product_Support_Queue' LIMIT 1];

    for (Case cs : cases) {
      Case child = new Case(
        BusinessHoursId = cs.BusinessHoursId,
        Case_Owner_is_Queue__c = true,
        CurrencyIsoCode = cs.CurrencyIsoCode,
        Description = cs.Description,
        OwnerId = productSuportQueue.Id,
        ParentId = cs.Id,
        RecordTypeId = cs.RecordTypeId,
        Related_To__c = cs.Related_To__c,
        Status = 'New',
        Sub_Component__c = cs.Sub_Component__c,
        Subject = 'DSAT FollowUp: ' + cs.Subject
      );
      children.add(child);
    }

    if (!children.isEmpty()) {
      insert children;
    }
  }

  public static void createChildCases(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Status, Case.CSAT__c },
      cases,
      existingCases
    );

    List<Case> eligibleCases = Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(new Set<String>{ CaseMetadata.IncidentRecordType })
          .also(Case.Status)
          .equals('Closed')
          .also(Case.CSAT__c)
          .lessThanOrEquals(2)
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      if (!isAlreadyRun) {
        isAlreadyRun = true;
        AbstractQueueable.enqueue(new CaseCreateChildCaseQueueable(eligibleCases));
      }
    }
  }
}
