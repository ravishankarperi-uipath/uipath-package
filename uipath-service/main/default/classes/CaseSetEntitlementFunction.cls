public with sharing class CaseSetEntitlementFunction implements SObjectToSObjectFunction {
  private Map<Id, Case> parentCaseMap;

  public CaseSetEntitlementFunction(List<Case> cases) {
    Set<Id> parentCaseIds = new Set<Id>();
    for (Case record : cases) {
      parentCaseIds.add(record.ParentId);
    }
    parentCaseMap = new Map<Id, Case>(
      [SELECT Id, EntitlementId FROM Case WHERE Id IN :parentCaseIds AND EntitlementId != null]
    );
  }

  public SObject apply(Case caseRecord) {
    if (parentCaseMap.get(caseRecord.ParentId) != null) {
      caseRecord.EntitlementId = parentCaseMap.get(caseRecord.ParentId).EntitlementId;
    }
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveEntitlement(List<Case> records) {
    Collection.of(records)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{ CaseMetadata.EngagementRequestRecordType, CaseMetadata.JapanEngagementRequestRecordType }
          )
      )
      .mapSome(
        Match.field(Case.EntitlementId).equals(null).also(Case.ParentId).hasValue(),
        new CaseSetEntitlementFunction(records)
      );
  }
}
