/**
 * Sets Standard_Template_Stamp__c according to Standard_Template__c.
 */
public class SalesCaseStandardTemplateStampFunction implements SObjectToSObjectFunction {
  public SalesCaseStandardTemplateStampFunction(List<Case> cases) {
  }

  public SObject apply(Case record) {
    record.Standard_Template_Stamp__c = 'No';
    return record;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void setStandardTemplateStampOnInsert(List<Case> records) {
    Collection.of(records)
      .filter(Match.field(Case.Standard_Template__c).isIn(new Set<String>{ 'No', 'Customer Template' }))
      .mapAll(new SalesCaseStandardTemplateStampFunction(records));
  }

  public static void setStandardTemplateStampOnUpdate(List<SObject> cases, Map<Id, SObject> existingCases) {
    HasRecordChanged templateChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Standard_Template__c },
      cases,
      existingCases
    );

    Collection.of(cases)
      .filter(templateChanged)
      .filter(Match.field(Case.Standard_Template__c).isIn(new Set<String>{ 'No', 'Customer Template' }))
      .mapAll(new SalesCaseStandardTemplateStampFunction(cases));
  }
}
