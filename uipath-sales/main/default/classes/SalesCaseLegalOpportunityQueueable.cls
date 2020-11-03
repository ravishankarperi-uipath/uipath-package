public without sharing class SalesCaseLegalOpportunityQueueable extends AbstractQueueable {
  private final List<SObject> cases;
  private static Boolean isAlreadyRun = false;

  public SalesCaseLegalOpportunityQueueable(List<Case> cases) {
    super('SalesCaseLegalOpportunityQueueable');
    this.cases = cases;
  }

  public override void work() {
    this.updateCaseCount(this.cases);
  }

  private void updateCaseCount(List<Case> cases) {
    List<Id> opportunityIds = Collection.of(cases).pluckIds(Case.Opportunity__c);
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    for (
      Opportunity opp : [
        SELECT
          Id,
          (
            SELECT Id
            FROM Cases__r
            WHERE
              RecordTypeId IN (
                :SalesCaseMetadata.UiPathJapanPartnerStandardRecordType,
                :SalesCaseMetadata.LegalRequestRecordType
              )
          )
        FROM Opportunity
        WHERE CurrencyISOCode = 'JPY' AND Id IN :opportunityIds
      ]
    ) {
      Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
      oppToUpdate.Number_of_Legal_Cases__c = opp.Cases__r.size();
      opportunitiesToUpdate.add(oppToUpdate);
    }
    update opportunitiesToUpdate;
  }

  public static void deriveCaseCount(List<Case> records) {
    List<Case> eligibleCases = (List<Case>) Collection.of(records)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              SalesCaseMetadata.LegalRequestRecordType,
              SalesCaseMetadata.UiPathJapanPartnerStandardRecordType
            }
          )
          .also(Case.Opportunity__c)
          .hasValue()
      )
      .asList();
    if (!eligibleCases.isEmpty() && !isAlreadyRun) {
      isAlreadyRun = true;
      AbstractQueueable.enqueue(new SalesCaseLegalOpportunityQueueable(records));
    }
  }
}
