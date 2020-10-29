public with sharing class SalesCaseOwnerAssignmentFunction implements SObjectToSObjectFunction {
  private Map<Id, Id> salesOwnerMap;
  public SalesCaseOwnerAssignmentFunction(List<Case> cases) {
    salesOwnerMap = new Map<Id, Id>();
    for (Case caseRecord : [
      SELECT Id, Account.OwnerId, Opportunity__c, Opportunity__r.OwnerId
      FROM Case
      WHERE Id IN :cases
    ]) {
      Id ownerId = (caseRecord.Opportunity__c != null) ? caseRecord.Opportunity__r.OwnerId : caseRecord.Account.OwnerId;
      salesOwnerMap.put(caseRecord.Id, ownerId);
    }
  }

  public SObject apply(Case caseRecord) {
    if (caseRecord.Status == SalesCaseMetadata.PENDING_SALES_INFORMATION) {
      caseRecord.OwnerId = salesOwnerMap.get(caseRecord.Id);
    } else if (
      (caseRecord.RecordTypeId == SalesCaseMetadata.LegalRequestRecordType ||
      caseRecord.RecordTypeId == SalesCaseMetadata.LegalProductRequestRecordType) &&
      caseRecord.Status == SalesCaseMetadata.IN_PROGRESS &&
      caseRecord.Legal_Owner__c != null
    ) {
      caseRecord.OwnerId = caseRecord.Legal_Owner__c;
    } else if (caseRecord.Status == SalesCaseMetadata.DEAL_HUB_REVIEW && caseRecord.Deal_Hub_Owner__c != null) {
      caseRecord.OwnerId = caseRecord.Deal_Hub_Owner__c;
    } else if (caseRecord.Status == SalesCaseMetadata.FINANCE_REVIEW && caseRecord.Finance_Owner__c != null) {
      caseRecord.OwnerId = caseRecord.Finance_Owner__c;
    } else if (caseRecord.Status == SalesCaseMetadata.LEGAL_REVIEW && caseRecord.Legal_Owner__c != null) {
      caseRecord.OwnerId = caseRecord.Legal_Owner__c;
    } else if (
      caseRecord.RecordTypeId == SalesCaseMetadata.LegalRequestRecordType &&
      caseRecord.Status == SalesCaseMetadata.READY_FOR_SIGNATURE &&
      caseRecord.Deal_Hub_Owner__c != null
    ) {
      caseRecord.OwnerId = caseRecord.Deal_Hub_Owner__c;
    } else if (
      caseRecord.RecordTypeId == SalesCaseMetadata.FinanceRequestRecordType &&
      caseRecord.Status == SalesCaseMetadata.MASTER_DATA_REVIEW &&
      caseRecord.Master_Data_Owner__c != null
    ) {
      caseRecord.OwnerId = caseRecord.Master_Data_Owner__c;
    }
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveOwnerOnUpdate(List<Case> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Status, Case.RecordTypeId },
      cases,
      existingCases
    );

    Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.Status)
          .isIn(
            new Set<String>{
              SalesCaseMetadata.PENDING_SALES_INFORMATION,
              SalesCaseMetadata.IN_PROGRESS,
              SalesCaseMetadata.DEAL_HUB_REVIEW,
              SalesCaseMetadata.FINANCE_REVIEW,
              SalesCaseMetadata.LEGAL_REVIEW,
              SalesCaseMetadata.READY_FOR_SIGNATURE,
              SalesCaseMetadata.MASTER_DATA_REVIEW
            }
          )
      )
      .mapAll(new SalesCaseOwnerAssignmentFunction(cases));
  }
}
