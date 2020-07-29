/**
 * TODO refactor code in next iteration
 */
@isTest
public class LicensingApexTriggerAccountTest {
  @isTest
  static void testUpdate() {
    Account o = newAccount();
    Test.setMock(HttpCalloutMock.class, new LicensingMockHttpResponse());

    LicensingApi.lastEndpoints.clear();
    Test.startTest();
    insert o;
    update o;
    Test.stopTest();

    System.assert(
      LicensingApi.lastEndpoints.get(0).endsWith('/account/' + o.get('id')),
      'LicensingApi test failed'
    );
  }

  @isTest
  static void testMerge() {
    Account master = newAccount();
    Account[] duplicates = new List<Account>{ newAccount(), newAccount() };

    Test.setMock(HttpCalloutMock.class, new LicensingMockHttpResponse());
    insert master;
    insert duplicates;
    LicensingApi.lastEndpoints.clear();
    Test.startTest();
    Database.merge(master, duplicates, false);
    Test.stopTest();

    Boolean mergeEndpointHit = false;
    for (String endpoint : LicensingApi.lastEndpoints) {
      if (endpoint.endsWith('/account/' + master.get('id') + '/merge')) {
        mergeEndpointHit = true;
        break;
      }
    }
    System.assert(mergeEndpointHit, 'Licensing merge is not working');
  }

  static Account newAccount() {
    Account acc = new Account(
      Name = 'MyAccount' + (Math.random() * 1000),
      BillingCountry = 'Romania',
      Industry = 'Automotive',
      Overwrite_Classification__c = true
    );
    return acc;
  }
}
