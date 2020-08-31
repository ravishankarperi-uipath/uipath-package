/**
 * Set Parent Case's Has_ER__c field to true if the Case RecordType is Engagement
 */
public with sharing class SetParentERQueueable extends AbstractQueueable {
  private final List<SObject> cases;

  public SetParentERQueueable(List<SObject> cases) {
    super('SetParentERQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.setER(this.cases);
  }

  private void setER(List<Case> cases) {
    Set<Id> parentCasesIds = new Set<Id>();

    for (Case cs : cases) {
      parentCasesIds.add(cs.ParentId);
    }

    List<Case> parents = [SELECT Id, Has_ER__c FROM Case WHERE Id IN :parentCasesIds];

    for (Case cs : parents) {
      cs.Has_ER__c = true;
    }

    if (!parents.isEmpty()) {
      update parents;
    }
  }

  public static void deriveParentEROnInsert(List<SObject> cases) {
    List<Account> eligibleCases = Collection.of(cases)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{ CaseMetadata.EngagementRequestRecordType, CaseMetadata.JapanEngagementRequestRecordType }
          )
          .also(Case.ParentId)
          .hasValue()
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      AbstractQueueable.enqueue(new SetParentERQueueable(eligibleCases));
    }
  }
}
