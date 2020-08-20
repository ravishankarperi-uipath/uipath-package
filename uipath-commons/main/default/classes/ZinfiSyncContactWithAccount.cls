/**
 * TODO refactor code in next iteration
 */
@SuppressWarnings('PMD')
public class ZinfiSyncContactWithAccount {
  @future(callout=true)
  public static void sendContactFutureCall(Set<Id> IdList) {
    ZinfiConfiguration__c zinfiSetting = ZinfiConfiguration__c.getInstance();
    List<ContactWrapper> WList = new List<ContactWrapper>();

    Set<String> contactFieldsToSync = new Set<String>{
      'FirstName',
      'LastName',
      'Email',
      'Id',
      'MailingCountry',
      'MailingState',
      'Direct_Phone__c',
      'Title',
      'AccountId'
    };

    // remove fields which are not present in the org
    Map<String, Schema.SobjectField> fieldMap = Schema.Contact.sObjectType.getDescribe().fields.getMap();
    for (String conField : contactFieldsToSync) {
      if (!fieldMap.containsKey(conField)) {
        contactFieldsToSync.remove(conField);
      }
    }

    List<Contact> CList = Database.query(
      'SELECT ' +
      String.join(new List<String>(contactFieldsToSync), ',') +
      ' FROM Contact' +
      ' WHERE Account.Business_Partner_Status__c=\'Good Standing\' ' +
      ' AND Account.Partner_Portal_Contact_Sync__c=true' +
      ' AND AccountId IN :IdList'
    );

    for (Contact n : CList) {
      ContactWrapper nw = new ContactWrapper();
      nw.ID = getDataFromSObject(n, 'Id');
      nw.FirstName = getDataFromSObject(n, 'FirstName');
      nw.LastName = getDataFromSObject(n, 'LastName');
      nw.EMAIL = getDataFromSObject(n, 'Email');
      nw.MailingCountry = getDataFromSObject(n, 'MailingCountry');
      nw.MailingState = getDataFromSObject(n, 'MailingState');
      nw.DirectPhone = getDataFromSObject(n, 'Direct_Phone__c');
      nw.Title = getDataFromSObject(n, 'Title');
      nw.AccountID = getDataFromSObject(n, 'AccountId');
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
    hr.setHeader('WebHook', zinfiSetting.WebHookContact__c);
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

  public class ContactWrapper {
    public string ID;
    public string FirstName;
    public string LastName;
    public string EMAIL;
    public string MailingCountry;
    public string MailingState;
    public string DirectPhone;
    public string Title;
    public string AccountID;
  }

  /**
   * If field is not present in the org then return blank
   */
  private static String getDataFromSObject(SObject sObj, String fieldName) {
    try {
      return sObj.get(fieldName) + '';
    } catch (Exception e) {
      return '';
    }
  }

  /**
   * TODO refactor code into Queueable
   * Sync data with Zinfi system
   */
  public static void zinfiSyncAccountOnUpdate(Map<Id, SObject> existingRecords) {
    ZinfiConfiguration__c zinfiSetting = ZinfiConfiguration__c.getInstance();
    if (zinfiSetting != null && zinfiSetting.IsSyncAccount__c) {
      ZinfiSyncContactWithAccount.sendContactFutureCall(existingRecords.keySet());
    }
  }
}
