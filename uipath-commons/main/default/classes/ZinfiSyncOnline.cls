/**
 * TODO refactor code in next iteration
 */
@SuppressWarnings('PMD')
public class ZinfiSyncOnline {
  @future(callout=true)
  public static void sendAccountFutureCall(Set<Id> IdList) {
    ZinfiConfiguration__c zinfiSetting = ZinfiConfiguration__c.getInstance();
    List<AccountWrapper> WList = new List<AccountWrapper>();
    /* List<Account> SoList = [SELECT Id,Name 
        FROM Account
        Where ID in:IdList];
        */
    for (string n : IdList) {
      AccountWrapper nw = new AccountWrapper();
      nw.Id = n;
      nw.Name = 'Name';
      WList.add(nw);
    }
    String strbdy = JSON.serialize(WList);
    System.debug(':::strbdy=' + strbdy);
    Http htp = new Http();
    HttpRequest hr = new HttpRequest();
    hr.setMethod('POST');
    hr.setEndPoint(zinfiSetting.WebhookEndPoint__c);

    hr.setBody(strbdy);
    hr.setHeader('Content-Type', 'application/json');
    hr.setHeader('Accept', 'application/json');
    hr.setHeader('WebToken', zinfiSetting.WebToken__c);
    hr.setHeader('WebHook', zinfiSetting.WebHook__c);
    System.debug(':::hr=' + hr);
    try {
      HttpResponse hs = htp.send(hr);
      String rsStr = hs.getBody();
      System.debug('***** response=' + rsStr);
      System.debug('***** StatusCode =' + hs.getStatusCode());
    } catch (Exception e) {
      System.debug('***** Exception=' + e.getMessage());
    }
  }

  public class AccountWrapper {
    public string Id;
    public string Name;
  }
}
