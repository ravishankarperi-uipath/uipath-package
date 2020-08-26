/**
 * TODO REWRITE
 * Move to Service Layer
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 * Inserts the Living Summary History on field changes
 */
public with sharing class CaseLivingSummaryQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private final Map<Id, SObject> oldCasessMap;
  public CaseLivingSummaryQueueable(List<SObject> cases, Map<Id, SObject> oldCasessMap) {
    super('CaseLivingSummaryQueueable');
    this.cases = cases;
    this.oldCasessMap = oldCasessMap;
  }

  public override void work() {
    System.debug('CaseLivingSummaryQueueable work');
    this.createLivingSummaryHistory(cases, oldCasessMap);
  }

  public void createLivingSummaryHistory(List<Case> cases, Map<Id, SObject> existingCases) {
    Set<SObjectField> caseFields = new Set<SObjectField>{
      Case.Problem__c,
      Case.Cause__c,
      Case.Validation__c,
      Case.Solution__c,
      Case.Solution_Instructions__c
    };
    SObjectPredicate hasChanged = new HasRecordChanged(caseFields, cases, existingCases);
    List<Case> eligibleCases = (List<Case>) Collection.of(cases).filter(hasChanged).asList();

    if (!eligibleCases.isEmpty()) {
      List<Living_Summary_History__c> livingSummaryHistoryList = new List<Living_Summary_History__c>();
      for (Case newCase : eligibleCases) {
        Case oldCase = (Case) existingCases.get(newCase.Id);
        oldCase.get(Case.Problem__c);
        for (SObjectField caseField : caseFields) {
          if (oldCase.get(caseField) != newCase.get(caseField)) {
            Living_Summary_History__c livingSummary = new Living_Summary_History__c();
            livingSummary.Case__c = newCase.Id;
            livingSummary.Field_Name__c = caseField.getDescribe().getName();
            livingSummary.New_Value__c = (String) newCase.get(caseField);
            livingSummary.Old_Value__c = (String) oldCase.get(caseField);
            livingSummaryHistoryList.add(livingSummary);
            break;
          }
        }
      }
      if (!livingSummaryHistoryList.isEmpty()) {
        System.debug(livingSummaryHistoryList.size());
        System.debug(livingSummaryHistoryList);

        insert livingSummaryHistoryList;
      }
    }
  }
}
