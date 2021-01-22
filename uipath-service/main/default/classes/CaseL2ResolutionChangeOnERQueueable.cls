public with sharing class CaseL2ResolutionChangeOnERQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private static Boolean isAlreadyRun = false;

  public CaseL2ResolutionChangeOnERQueueable(List<SObject> cases) {
    super('CaseL2ResolutionChangeOnERQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.updateChildNotification(cases);
  }

  private void updateChildNotification(List<Case> cases) {
    List<Case> parentCases = new List<Case>();
    for (Case record : [
      SELECT Id, CaseNumber, ParentId, Resolution_from_L2__c
      FROM Case
      WHERE Parent.Status != 'Closed' AND Id IN :cases
    ]) {
      Case parent = new Case();
      parent.Id = record.ParentId;
      parent.Child_case_Updates_Notification__c =
        'Resolution from L2 is updated with this value ' +
        record.Resolution_from_L2__c +
        ' in the case number #' +
        record.CaseNumber;
      parentCases.add(parent);
    }
    if (!parentCases.isEmpty()) {
      update parentCases;
    }
  }

  public static void setChildCaseUpdateNotificationOnParent(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Resolution_from_L2__c },
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
          .also(Case.Resolution_from_L2__c)
          .hasValue()
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      if (!isAlreadyRun) {
        isAlreadyRun = true;
        AbstractQueueable.enqueue(new CaseL2ResolutionChangeOnERQueueable(eligibleCases));
      }
    }
  }
}
