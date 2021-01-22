public with sharing class CaseProactiveServiceFunction implements SObjectToSObjectFunction {
  private Map<Id, Account> accountMap;

  public CaseProactiveServiceFunction(List<Case> cases) {
    Set<Id> accountIds = new Set<Id>();
    for (Case record : cases) {
      accountIds.add(record.AccountId);
    }
    accountMap = new Map<Id, Account>(
      [
        SELECT Id, Support_Technical_Advisor__c
        FROM Account
        WHERE
          Id IN :accountIds
          AND Support_Technical_Advisor__c != null
          AND Support_Technical_Advisor__r.IsActive = true
      ]
    );
  }

  public SObject apply(Case record) {
    if (accountMap.get(record.AccountId) != null) {
      record.OwnerId = accountMap.get(record.AccountId).Support_Technical_Advisor__c;
    }
    return record;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void assignToSupportTechnicalAdvisor(List<Case> records) {
    Collection.of(records)
      .mapSome(
        Match.field(Case.AccountId).hasValue().also(Case.RecordTypeId).equals(CaseMetadata.ProactiveCareRecordType),
        new CaseProactiveServiceFunction(records)
      );
  }
}
