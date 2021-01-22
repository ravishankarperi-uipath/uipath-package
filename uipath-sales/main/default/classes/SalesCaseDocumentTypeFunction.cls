public with sharing class SalesCaseDocumentTypeFunction implements SObjectToSObjectFunction {
  private Map<Id, String> accountToCountryMap;
  public static final String NON_EDITABLE_STANDARD = 'UiPath Template Non-Editable (Standard)';
  private List<String> EXCLUDED_COUNTRIES = new List<String>{
    'Russian Federation',
    'Armenia',
    'Belarus',
    'Kasakhstan',
    'Kyrgyzstan',
    'Turkmenistan',
    'Uzbekistan',
    'Ukraine',
    'Georgia',
    'Azerbaijan'
  };

  public SalesCaseDocumentTypeFunction(List<Case> cases) {
    Set<Id> accountIds = new Set<Id>(Collection.of(cases).pluckIds());
    accountToCountryMap = new Map<Id, String>();
    for (Account account : [SELECT Id, BillingCountry FROM Account WHERE Id IN :accountIds]) {
      accountToCountryMap.put(account.Id, account.BillingCountry);
    }
  }

  public SObject apply(Case record) {
    Boolean assignTemplate = false;
    if (record.Document_Type__c.startsWith('EAAP Agreement')) {
      if (record.AI_Early_Access_Program__c != null) {
        assignTemplate = true;
      }
    } else if (record.Document_Type__c == 'USN Addendum') {
      if (
        record.Standard_Template__c == SalesCaseMetadata.NON_EDITABLE_STANDARD &&
        !EXCLUDED_COUNTRIES.contains(accountToCountryMap.get(record.AccountId))
      ) {
        assignTemplate = true;
      }
    } else if (record.Document_Type__c == 'Undertaking by Original Software Developer (for Software) pre Signed') {
      if (record.Standard_Template__c == SalesCaseMetadata.NON_EDITABLE_STANDARD) {
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
          .isIn(SalesCaseMetadata.DocumentTypeMapping.keySet())
          .also(Case.Document_Type__c)
          .hasValue()
      )
      .mapAll(new SalesCaseDocumentTypeFunction(records));
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
          .isIn(SalesCaseMetadata.DocumentTypeMapping.keySet())
          .also(Case.Document_Type__c)
          .hasValue()
      )
      .mapAll(new SalesCaseDocumentTypeFunction(records));
  }
}
