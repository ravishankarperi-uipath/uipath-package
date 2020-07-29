/**
 * TODO refactor code in next iteration
 */
public class LicensingApi {
  public static List<String> lastEndpoints = new List<String>();

  @future(callout=true)
  public static void onAccountUpdate(string callout, string accountId) {
    try {
      System.debug(
        'BOON: LicensingApi.onAccountUpdate started on accountId=' + accountId
      );
      HttpRequest request = new HttpRequest();
      String endpoint = 'callout:' + callout + '/account/' + accountId;
      request.setEndpoint(endpoint);
      request.setMethod('PUT');
      if (Test.isRunningTest()) {
        lastEndpoints.add(endpoint);
      }
      Http http = new Http();
      HTTPResponse response = http.send(request);
      System.debug('BOON: LicensingApi.onAccountUpdate response:' + response);
      System.debug('BOON: LicensingApi.onAccountUpdate finished');
    } catch (Exception e) {
      System.debug('BOON: Error: ' + e);
    }
  }

  @future(callout=true)
  public static void onAccountsMerged(
    string callout,
    string masterAccountId,
    List<string> mergedAccountIds
  ) {
    try {
      System.debug(
        'BOON: LicensingApi.onAccountsMerged started on masterAccountId=' +
        masterAccountId
      );
      HttpRequest request = new HttpRequest();
      String endpoint =
        'callout:' +
        callout +
        '/account/' +
        masterAccountId +
        '/merge';
      request.setEndpoint(endpoint);
      request.setMethod('PUT');
      if (Test.isRunningTest()) {
        lastEndpoints.add(endpoint);
      }
      Http http = new Http();
      String arr = JSON.serialize(mergedAccountIds);
      request.setBody(arr);
      request.setHeader('Content-Type', 'application/json');
      HTTPResponse response = http.send(request);
      System.debug('BOON: LicensingApi.onAccountsMerged response:' + response);
      System.debug('BOON: LicensingApi.onAccountsMerged finished');
    } catch (Exception e) {
      System.debug('BOON: Error: ' + e);
    }
  }
}
