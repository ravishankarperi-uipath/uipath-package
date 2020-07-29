/**
 * TODO refactor code in next iteration
 */
public with sharing class LicensingApiDispatch {
  public static void onAccountUpdate(string accountId) {
    for (Licensing_Environment__mdt env : getEnvironments()) {
      LicensingApi.onAccountUpdate(env.Licensing_Server_Callout__c, accountId);
    }
  }

  public static void onAccountsMerged(
    string masterAccountId,
    List<string> mergedAccountIds
  ) {
    for (Licensing_Environment__mdt env : getEnvironments()) {
      LicensingApi.onAccountsMerged(
        env.Licensing_Server_Callout__c,
        masterAccountId,
        mergedAccountIds
      );
    }
  }

  private static Licensing_Environment__mdt[] getEnvironments() {
    if (Test.isRunningTest()) {
      return new List<Licensing_Environment__mdt>{
        new Licensing_Environment__mdt(
          Licensing_Server_Callout__c = 'test',
          Enabled__c = true
        )
      };
    }
    return [
      SELECT Licensing_Server_Callout__c, Enabled__c
      FROM Licensing_Environment__mdt
      WHERE Enabled__c = true
    ];
  }
}
