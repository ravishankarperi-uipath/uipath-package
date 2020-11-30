/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates the Child case Updates Notification on the parent case when certain fields change on the ER case
 */
public with sharing class CaseOwnerChangeOnERQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private static Boolean isAlreadyRun = false;

  public CaseOwnerChangeOnERQueueable(List<SObject> cases) {
    super('CaseOwnerChangeOnERQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.updateChildNotification(cases);
  }

  private void updateChildNotification(List<Case> cases) {
    List<Case> parentCases = new List<Case>();
    for (Case record : [SELECT Id, ParentId, Owner.Name FROM Case WHERE Parent.Status != 'Closed' AND Id IN :cases]) {
      Case parent = new Case();
      parent.Id = record.ParentId;
      parent.Child_case_Updates_Notification__c = 'Case Owner value is changed to ' + record.Owner.Name;
      parentCases.add(parent);
    }
    if (!parentCases.isEmpty()) {
      update parentCases;
    }
  }

  public static void setChildCaseUpdateNotificationOnParent(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(new Set<SObjectField>{ Case.OwnerId }, cases, existingCases);

    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(hasChanged)
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
      if (!isAlreadyRun) {
        isAlreadyRun = true;
        AbstractQueueable.enqueue(new CaseOwnerChangeOnERQueueable(eligibleCases));
      }
    }
  }
}
