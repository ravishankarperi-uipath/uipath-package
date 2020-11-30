public with sharing class CaseStatusChangeOnERQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private static Boolean isAlreadyRun = false;

  public CaseStatusChangeOnERQueueable(List<SObject> cases) {
    super('CaseStatusChangeOnERQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.updateChildNotification(cases);
  }

  private void updateChildNotification(List<Case> cases) {
    List<Case> parentCases = new List<Case>();
    for (Case record : [
      SELECT Id, CaseNumber, ParentId, Status
      FROM Case
      WHERE Parent.Status != 'Closed' AND Id IN :cases
    ]) {
      Case parent = new Case();
      parent.Id = record.ParentId;
      parent.Child_case_Updates_Notification__c =
        'Status is changed to this ' +
        record.Status +
        ' in the case number #' +
        record.CaseNumber;
      parentCases.add(parent);
    }
    if (!parentCases.isEmpty()) {
      update parentCases;
    }
  }

  public static void setChildCaseUpdateNotification(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(new Set<SObjectField>{ Case.Status }, cases, existingCases);

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
        AbstractQueueable.enqueue(new CaseStatusChangeOnERQueueable(eligibleCases));
      }
    }
  }
}
