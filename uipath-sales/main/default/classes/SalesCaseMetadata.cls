public without sharing class SalesCaseMetadata {
  public static final String TECHNOLOGY_ALLIANCE_AGREEMENT = 'Technology Alliance Agreement';
  public static final String SIGNED = 'Signed';
  public static final String NOT_SIGNED = 'Not Signed';

  private static final String LEGAL_PRODUCT_REQUEST = 'Legal_Product_Request';

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
}
