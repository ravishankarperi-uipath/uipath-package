/**
 * TODO refactor code in next iteration
 */
public with sharing class LicensingApiDispatch {
  public static void onAccountUpdate(string accountId) {
    for (Licensing_Environment__mdt env : getEnvironments()) {
      LicensingApi.onAccountUpdate(env.Licensing_Server_Callout__c, accountId);
    }
  }

  public static void onAccountsMerged(string masterAccountId, List<string> mergedAccountIds) {
    for (Licensing_Environment__mdt env : getEnvironments()) {
      LicensingApi.onAccountsMerged(env.Licensing_Server_Callout__c, masterAccountId, mergedAccountIds);
    }
  }

  private static Organization orgInfo {
    get {
      if (orgInfo == null) {
        orgInfo = [SELECT IsSandbox FROM Organization LIMIT 1];
      }
      return orgInfo;
    }
    set;
  }

  private static Licensing_Environment__mdt[] getEnvironments() {
    //test setting
    if (Test.isRunningTest()) {
      return new List<Licensing_Environment__mdt>{
        new Licensing_Environment__mdt(Licensing_Server_Callout__c = 'test', Enabled__c = true)
      };
    }

    //production setting
    if (orgInfo.IsSandbox == false) {
      return [
        SELECT Licensing_Server_Callout__c, Enabled__c
        FROM Licensing_Environment__mdt
        WHERE Enabled__c = true AND DeveloperName = 'Production'
      ];
    }

    //sandbox setting
    return [
      SELECT Licensing_Server_Callout__c, Enabled__c
      FROM Licensing_Environment__mdt
      WHERE Enabled__c = true AND DeveloperName = 'Sandbox'
    ];
  }

  /**
   * TODO refactor code into Queueable
   * Sync data using licensing Api
   */
  public static void licensingApiSyncAccountOnDelete(List<Account> records) {
    Map<String, List<String>> masterRecordIdAccMap = new Map<String, List<String>>();
    for (Account acc : (List<Account>) records) {
      if (acc.MasterRecordId != null) {
        if (!masterRecordIdAccMap.containsKey(acc.MasterRecordId)) {
          masterRecordIdAccMap.put(acc.MasterRecordId, new List<String>());
        }
        masterRecordIdAccMap.get(acc.MasterRecordId).add(acc.Account_ID_Long__c);
      }
    }
    for (String masterRecordId : masterRecordIdAccMap.keySet()) {
      if ((Limits.getLimitFutureCalls() - Limits.getFutureCalls()) > 0) {
        LicensingApiDispatch.onAccountsMerged(masterRecordId, masterRecordIdAccMap.get(masterRecordId));
      }
    }
  }

  /**
   * TODO refactor code into Queueable
   * Sync data using licensing Api
   */
  public static void licensingApiSyncAccountOnUpdate(List<Account> records, Map<Id, SObject> oldMap) {
    for (Account acc : records) {
      Account oldAcc = (Account) oldMap.get(acc.Id);
      if (
        acc.Account_ID_Long__c != oldAcc.Account_ID_Long__c ||
        acc.Name != oldAcc.Name ||
        acc.ParentId != oldAcc.ParentId ||
        acc.Type != oldAcc.Type ||
        acc.Industry != oldAcc.Industry ||
        acc.BillingCountryCode != oldAcc.BillingCountryCode ||
        acc.Geo__c != oldAcc.Geo__c ||
        acc.Area__c != oldAcc.Area__c ||
        acc.Region__c != oldAcc.Region__c ||
        acc.Vertical__c != oldAcc.Vertical__c ||
        acc.recordTypeId != oldAcc.recordTypeId
      ) {
        if ((Limits.getLimitFutureCalls() - Limits.getFutureCalls()) > 0) {
          LicensingApiDispatch.onAccountUpdate(acc.Account_ID_Long__c);
        }
      }
    }
  }
}
