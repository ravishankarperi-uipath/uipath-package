public with sharing class CasePendingReasonChangeFunction implements SObjectToSObjectFunction {
  public CasePendingReasonChangeFunction(List<Case> cases) {
  }

  public SObject apply(Case record) {
    if (record.Awaiting_Pending_Reason__c == CaseMetadata.PENDING_FROM_PRODUCT) {
      record.Pending_Product_Timestamp__c = System.now();
    } else if (record.Awaiting_Pending_Reason__c == CaseMetadata.PENDING_FROM_INFRA) {
      record.Pending_Infra_MCS_Time_stamp__c = System.now();
    } else if (record.Awaiting_Pending_Reason__c == CaseMetadata.PENDING_FROM_SR_TECH) {
      record.Pending_Sr_Tech_Support_time_stamp__c = System.now();
    } else if (record.Awaiting_Pending_Reason__c == CaseMetadata.PENDING_FROM_TECH) {
      record.Pending_Tech_support_time_stamp__c = System.now();
    }
    return record;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void derivePendingTimestamps(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Awaiting_Pending_Reason__c },
      cases,
      existingCases
    );

    Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{ CaseMetadata.EngagementRequestRecordType, CaseMetadata.JapanEngagementRequestRecordType }
          )
          .also(Case.Awaiting_Pending_Reason__c)
          .hasValue()
          .also(Case.Awaiting_Pending_Reason__c)
          .isIn(
            new Set<String>{
              CaseMetadata.PENDING_FROM_PRODUCT,
              CaseMetadata.PENDING_FROM_INFRA,
              CaseMetadata.PENDING_FROM_SR_TECH,
              CaseMetadata.PENDING_FROM_TECH
            }
          )
      )
      .mapAll(new CasePendingReasonChangeFunction(cases));
  }
}
