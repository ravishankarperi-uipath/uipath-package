public with sharing class SalesCaseDocumentLanguageFunction implements SObjectToSObjectFunction {
  private Map<Id, String> accountToCountryMap;
  private List<String> INCLUDED_COUNTRIES = new List<String>{ 'China', 'Taiwan', 'Hong Kong' };

  public SalesCaseDocumentLanguageFunction(List<Case> cases) {
    Set<Id> accountIds = new Set<Id>(Collection.of(cases).pluckIds());
    accountToCountryMap = new Map<Id, String>();
    for (Account account : [SELECT Id, BillingCountry FROM Account WHERE Id IN :accountIds]) {
      accountToCountryMap.put(account.Id, account.BillingCountry);
    }
  }

  public SObject apply(Case record) {
    Boolean assignTemplate = false;
    if (
      record.Document_Type__c == 'MPA Indirect Resale + BPO Agreement (CN)' &&
      INCLUDED_COUNTRIES.contains(accountToCountryMap.get(record.AccountId))
    ) {
      assignTemplate = true;
    } else if (
      record.Document_Type__c == 'MPA Indirect Resale Only Agreement (CN)' &&
      accountToCountryMap.get(record.AccountId) == 'China'
    ) {
      assignTemplate = true;
    } else if (record.Document_Type__c == 'DPA') {
      if (
        record.Standard_Template__c == null ||
        record.Standard_Template__c == SalesCaseMetadata.NON_EDITABLE_STANDARD ||
        record.Standard_Template__c == SalesCaseMetadata.EDITABLE_STANDARD
      ) {
        assignTemplate = true;
      }
    } else {
      assignTemplate = true;
    }
    if (assignTemplate) {
      record.Conga_Template_2__c = SalesCaseMetadata.DocumentTypeMapping.get(record.Document_Type__c);
    }

    return record;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveTemplateId(List<Case> records) {
    Collection.of(records)
      .filter(
        Match.field(Case.Document_Type__c)
          .isIn(SalesCaseMetadata.DocumentTypesWithLanguages)
          .also(Case.Document_Type__c)
          .hasValue()
          .also(Case.Document_Language__c)
          .hasValue()
      )
      .mapAll(new SalesCaseDocumentLanguageFunction(records));
  }

  public static void deriveTemplateId(List<SObject> records, Map<Id, SObject> existingRecords) {
    HasRecordChanged hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Document_Type__c, Case.Document_Language__c },
      records,
      existingRecords
    );

    Collection.of(records)
      .filter(hasChanged)
      .filter(
        Match.field(Case.Document_Type__c)
          .isIn(SalesCaseMetadata.DocumentTypesWithLanguages)
          .also(Case.Document_Type__c)
          .hasValue()
          .also(Case.Document_Language__c)
          .hasValue()
      )
      .mapAll(new SalesCaseDocumentLanguageFunction(records));
  }
}
