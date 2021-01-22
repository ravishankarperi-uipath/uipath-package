/**
 * Sets Bill_To__c to AccountId before insert.
 */
public class SalesCaseBillToWOOppFunction implements SObjectToSObjectFunction {
  public SalesCaseBillToWOOppFunction(List<Case> cases) {
  }

  public SObject apply(Case record) {
    record.Bill_To__c = record.AccountId;
    return record;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void updateBillToOnInsert(List<Case> records) {
    Collection.of(records)
      .filter(Match.field(Case.RecordTypeId).isIn(new Set<String>{ SalesCaseMetadata.LegalRequestRecordType }))
      .mapSome(Match.field(Case.Opportunity__c).equals(null), new SalesCaseBillToWOOppFunction(records));
  }

  public static void updateBillToOnUpdate(List<SObject> cases, Map<Id, SObject> existingCases) {
    HasRecordChanged accountChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.AccountId },
      cases,
      existingCases
    );

    Collection.of(cases)
      .filter(accountChanged)
      .filter(Match.field(Case.RecordTypeId).isIn(new Set<String>{ SalesCaseMetadata.LegalRequestRecordType }))
      .mapSome(
        Match.field(Case.Opportunity__c).equals(null).also(Case.isClosed).equals(false),
        new SalesCaseBillToWOOppFunction(cases)
      );
  }
}
