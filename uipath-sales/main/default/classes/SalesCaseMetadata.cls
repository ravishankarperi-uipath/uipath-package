public without sharing class SalesCaseMetadata {
  public static final String TECHNOLOGY_ALLIANCE_AGREEMENT = 'Technology Alliance Agreement';
  public static final String SIGNED = 'Signed';
  public static final String NOT_SIGNED = 'Not Signed';
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

  public static Id FinanceRequestRecordType {
    get {
      return getRecordTypeId(FINANCE_REQUEST);
    }
    set;
  }
}
