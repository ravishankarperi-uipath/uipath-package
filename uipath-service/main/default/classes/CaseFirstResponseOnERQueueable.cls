/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Updates the Child case Updates Notification on the parent case when certain fields change on the ER case
 */
public with sharing class CaseFirstResponseOnERQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private static Boolean isAlreadyRun = false;
  public CaseFirstResponseOnERQueueable(List<SObject> cases) {
    super('CaseFirstResponseOnERQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.updateChildNotification(cases);
  }

  private void updateChildNotification(List<Case> cases) {
    List<Case> parentCases = new List<Case>();
    for (Case record : [
      SELECT Id, CaseNumber, ParentId, First_Response__c
      FROM Case
      WHERE Parent.Status != 'Closed' AND Id IN :cases
    ]) {
      Case parent = new Case();
      parent.Id = record.ParentId;
      parent.Child_case_Updates_Notification__c =
        'FR is updated with this value ' +
        record.First_Response__c +
        ' in the case number #' +
        record.CaseNumber;
      parentCases.add(parent);
    }
    if (!parentCases.isEmpty()) {
      update parentCases;
    }
  }

  public static void setChildCaseUpdateNotification(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.First_Response__c },
      cases,
      existingCases
    );

    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{ CaseMetadata.EngagementRequestRecordType, CaseMetadata.JapanEngagementRequestRecordType }
          )
          .also(Case.ParentId)
          .hasValue()
          .also(Case.First_Response__c)
          .hasValue()
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      if (!isAlreadyRun) {
        isAlreadyRun = true;
        AbstractQueueable.enqueue(new CaseFirstResponseOnERQueueable(eligibleCases));
        for (Case caseRecord : eligibleCases) {
          caseRecord.Status = 'In Process';
        }
      }
    }
  }
}
