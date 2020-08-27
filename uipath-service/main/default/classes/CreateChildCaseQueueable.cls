/**
 */
public with sharing class CreateChildCaseQueueable extends AbstractQueueable {
  private final List<SObject> cases;

  public CreateChildCaseQueueable(List<SObject> cases) {
    super('CreateChildCaseQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.createChildCase(this.cases);
  }

  private void createChildCase(List<SObject> cases) {
    List<Case> children = new List<Case>();

    Group productSuportQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND NAME = 'Product_Support_Queue'];

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
    SObjectPredicate hasChanged = new HasRecordChanged(new Set<SObjectField>{ Case.CSAT__c }, cases, existingCases);

    List<Account> eligibleCases = Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Account.RecordTypeId)
          .isIn(new Set<String>{ CaseMetadata.IncidentRecordType })
          .also(Case.Status)
          .equals('Closed')
          .also(Case.CSAT__c)
          .greaterThanOrEquals(2)
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      AbstractQueueable.enqueue(new CreateChildCaseQueueable(eligibleCases));
    }
  }
}
