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

    for (Case case : cases) {
      Case child = new Case(
        BusinessHoursId = case.BusinessHoursId,
        Case_Owner_is_Queue__c = true,
        CurrencyIsoCode = case.CurrencyIsoCode,
        Description = case.Description,
        OwnerId = productSuportQueue.Id,
        ParentId = case.Id,
        RecordTypeId = case.RecordTypeId,
        Related_To__c = case.Related_To__c,
        Status = 'New',
        Sub_Component__c = case.Sub_Component__c,
        Subject = 'DSAT FollowUp: ' + Case.Subject
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
      AbstractQueueable.enqueue(new CreateChildCaseQueueable(eligibleCases, null));
    }
  }
}
