/**
 * TODO refactor code in next iteration
 */
@isTest
public class LicensingMockHttpResponse implements HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setStatusCode(200);
    return res;
  }
}
