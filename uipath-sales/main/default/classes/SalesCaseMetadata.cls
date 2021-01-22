public without sharing class SalesCaseMetadata {
  public static final String TECHNOLOGY_ALLIANCE_AGREEMENT = 'Technology Alliance Agreement';
  public static final String SIGNED = 'Signed';
  public static final String NOT_SIGNED = 'Not Signed';

  public static final String NON_EDITABLE_STANDARD = 'UiPath Template Non-Editable (Standard)';
  public static final String EDITABLE_STANDARD = 'UiPath Template Editable';

  //Cases Status
  public static final String PENDING_SALES_INFORMATION = 'Pending Sales Information';
  public static final String IN_PROGRESS = 'In Progress';
  public static final String DEAL_HUB_REVIEW = 'Deal Hub Review';
  public static final String FINANCE_REVIEW = 'Finance Review';
  public static final String LEGAL_REVIEW = 'Legal Review';
  public static final String READY_FOR_SIGNATURE = 'Ready for signature';
  public static final String MASTER_DATA_REVIEW = 'Master Data Review';

  //RecordType API Names
  private static final String LEGAL_PRODUCT_REQUEST = 'Legal_Product_Request';
  private static final String LEGAL_REQUEST = 'Legal_Request';
  private static final String UIPATH_JAPAN_PARTNER_STANDARD = 'UiPath_Japan_Partner_standard';
  private static final String FINANCE_REQUEST = 'Finance_Request';

  public static Id getRecordTypeId(String developerName) {
    Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    return recordTypeId;
  }

  public static Id LegalProductRequestRecordType {
    get {
      return getRecordTypeId(LEGAL_PRODUCT_REQUEST);
    }
    set;
  }

  public static Id LegalRequestRecordType {
    get {
      return getRecordTypeId(LEGAL_REQUEST);
    }
    set;
  }

  public static Id UiPathJapanPartnerStandardRecordType {
    get {
      return getRecordTypeId(UIPATH_JAPAN_PARTNER_STANDARD);
    }
    set;
  }

  public static Id FinanceRequestRecordType {
    get {
      return getRecordTypeId(FINANCE_REQUEST);
    }
    set;
  }

  public static Map<String, String> DocumentTypeMapping {
    get {
      if (DocumentTypeMapping == null) {
        DocumentTypeMapping = new Map<String, String>();
        for (Template_Mapping__mdt templateMapping : [
          SELECT Id, IsActive__c, CongaTemplateId__c, DocumentType__c
          FROM Template_Mapping__mdt
          WHERE IsActive__c = true AND DocumentLanguage__c = null
        ]) {
          DocumentTypeMapping.put(templateMapping.DocumentType__c, templateMapping.CongaTemplateId__c);
        }
      }
      return DocumentTypeMapping;
    }
    set;
  }

  public static Set<String> DocumentTypesWithLanguages {
    get {
      if (DocumentTypesWithLanguages == null) {
        DocumentTypesWithLanguages = new Set<String>();
        for (Template_Mapping__mdt templateMapping : [
          SELECT Id, IsActive__c, CongaTemplateId__c, DocumentType__c
          FROM Template_Mapping__mdt
          WHERE IsActive__c = true AND DocumentLanguage__c != null
        ]) {
          DocumentTypesWithLanguages.add(templateMapping.DocumentType__c);
        }
      }
      return DocumentTypesWithLanguages;
    }
    set;
  }

  public static Map<String, String> DocumentTypeLanguageMapping {
    get {
      if (DocumentTypeLanguageMapping == null) {
        DocumentTypeLanguageMapping = new Map<String, String>();
        for (Template_Mapping__mdt templateMapping : [
          SELECT Id, IsActive__c, CongaTemplateId__c, DocumentType__c, DocumentLanguage__c
          FROM Template_Mapping__mdt
          WHERE IsActive__c = true AND DocumentLanguage__c != null
        ]) {
          DocumentTypeLanguageMapping.put(
            templateMapping.DocumentLanguage__c + templateMapping.DocumentType__c,
            templateMapping.CongaTemplateId__c
          );
        }
      }
      return DocumentTypeLanguageMapping;
    }
    set;
  }
}
