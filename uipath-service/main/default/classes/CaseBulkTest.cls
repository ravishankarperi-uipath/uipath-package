@IsTest
public class CaseBulkTest {
  @TestSetup
  static void makeData() {
    User adminUser = new User();
    adminUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    adminUser.Username = 'test839734@uiath.com';
    adminUser.LastName = 'Test';
    adminUser.Email = 'test839734@uiath.com';
    adminUser.Alias = 't839734';
    adminUser.TimeZoneSidKey = 'America/Los_Angeles';
    adminUser.LocaleSidKey = 'en_US';
    adminUser.EmailEncodingKey = 'UTF-8';
    adminUser.LanguageLocaleKey = 'en_US';
    insert adminUser;

    Case parentCase = new Case(
      Subject = 'Parent',
      Status = 'New',
      RecordTypeId = CaseMetadata.IncidentRecordType,
      Origin = 'Email',
      SuppliedEmail = 'test@test.com'
    );
    insert parentCase;
  }

  /**
   * Can insert 200 Cases in Bulk without Limits issues
   */
  @IsTest
  private static void canInsertCasesInBulkV1() {
    Case parentCase = [SELECT Id FROM Case LIMIT 1];

    List<Case> cases = new List<Case>();
    for (Integer i = 0; i < 200; i++) {
      cases.add(
        new Case(
          Subject = 'Test' + i,
          Status = 'New',
          RecordTypeId = CaseMetadata.EngagementRequestRecordType,
          ParentId = parentCase.Id,
          Copy_From_Parent_Case__c = true,
          No_of_Emails_Sent__c = 2
        )
      );
    }
    //will throw on any limits issues
    System.assertEquals(Database.insert(cases, true).size() > 0, true);
  }

  /**
   * Can insert 200 Cases in Bulk without Limits issues
   */
  @IsTest
  private static void canInsertCasesInBulkV2() {
    List<Case> cases = new List<Case>();
    for (Integer i = 0; i < 200; i++) {
      cases.add(
        new Case(
          Subject = 'Test' + i,
          Status = 'New',
          RecordTypeId = CaseMetadata.ServiceRequestRecordType,
          No_of_Emails_Sent__c = 2,
          Origin = 'Email',
          SuppliedEmail = 'test@test.com'
        )
      );
    }
    //will throw on any limits issues
    System.assertEquals(Database.insert(cases, true).size() > 0, true);
  }

  /**
   * Can update 200 Cases in Bulk without Limits issues
   */
  @IsTest
  private static void canUpdateCasesInBulkV1() {
    List<Case> cases = new List<Case>();
    Case parentCase = [SELECT Id FROM Case LIMIT 1];

    for (Integer i = 0; i < 200; i++) {
      cases.add(
        new Case(
          Subject = 'Test' + i,
          Status = 'New',
          First_Response__c = 'No text.',
          RecordTypeId = CaseMetadata.EngagementRequestRecordType,
          No_of_Emails_Sent__c = 1,
          Priority = 'Low',
          Awaiting_Pending_Reason__c = CaseMetadata.PENDING_FROM_PRODUCT,
          Copy_From_Parent_Case__c = false
        )
      );
    }
    insert cases;

    Test.startTest();
    User usr = [SELECT Id FROM User LIMIT 1];

    for (Integer i = 0; i < 200; i++) {
      cases.get(i).Status = 'In Progress';
      cases.get(i).ParentId = parentCase.Id;
      cases.get(i).First_Response__c = 'There is text.';
      cases.get(i).No_of_Emails_Sent__c = 2;
      cases.get(i).Priority = 'High';
      cases.get(i).Awaiting_Pending_Reason__c = CaseMetadata.PENDING_FROM_INFRA;
      cases.get(i).Copy_From_Parent_Case__c = true;
      cases.get(i).OwnerId = usr.Id;
    }
    //will throw on any limits issues
    List<Database.SaveResult> results = Database.update(cases, true);
    System.assertEquals(results.size() > 0, true);

    Test.stopTest();
  }

  /**
   * Can update 200 Cases in Bulk without Limits issues
   */
  @IsTest
  private static void canUpdateCasesInBulkV2() {
    List<Case> cases = new List<Case>();
    for (Integer i = 0; i < 200; i++) {
      cases.add(
        new Case(
          Subject = 'Test' + i,
          Status = 'New',
          RecordTypeId = CaseMetadata.ServiceRequestRecordType,
          No_of_Emails_Sent__c = 1,
          No_of_Emails_Received__c = 1,
          Priority = 'Low',
          Awaiting_Pending_Reason__c = CaseMetadata.PENDING_FROM_PRODUCT,
          Copy_From_Parent_Case__c = false
        )
      );
    }
    insert cases;

    Test.startTest();
    User usr = [SELECT Id FROM User LIMIT 1];

    for (Integer i = 0; i < 200; i++) {
      cases.get(i).Status = 'Resolved';
      cases.get(i).No_of_Emails_Received__c = 2;
      cases.get(i).No_of_Emails_Sent__c = 2;
      cases.get(i).Priority = 'High';
      cases.get(i).Awaiting_Pending_Reason__c = CaseMetadata.PENDING_FROM_PRODUCT;
      cases.get(i).Copy_From_Parent_Case__c = true;
      cases.get(i).OwnerId = usr.Id;
    }
    //will throw on any limits issues
    List<Database.SaveResult> results = Database.update(cases, true);
    System.assertEquals(results.size() > 0, true);

    Test.stopTest();
  }

  /**
   * Can update 200 Cases in Bulk without Limits issues
   */
  @IsTest
  private static void canUpdateCasesInBulkV3() {
    List<Case> cases = new List<Case>();
    for (Integer i = 0; i < 200; i++) {
      cases.add(
        new Case(
          Subject = 'Test' + i,
          Status = 'New',
          RecordTypeId = CaseMetadata.ServiceRequestRecordType,
          No_of_Emails_Sent__c = 1,
          No_of_Emails_Received__c = 1,
          Priority = 'Low',
          Awaiting_Pending_Reason__c = CaseMetadata.PENDING_FROM_PRODUCT,
          Copy_From_Parent_Case__c = false,
          IsClosed_NotifyOnMail__c = false
        )
      );
    }
    insert cases;

    Test.startTest();

    User usr = [SELECT Id FROM User LIMIT 1];

    for (Integer i = 0; i < 200; i++) {
      cases.get(i).Status = 'Closed';
      cases.get(i).No_of_Emails_Received__c = 2;
      cases.get(i).No_of_Emails_Sent__c = 2;
      cases.get(i).Priority = 'High';
      cases.get(i).Awaiting_Pending_Reason__c = CaseMetadata.PENDING_FROM_PRODUCT;
      cases.get(i).Copy_From_Parent_Case__c = true;
      cases.get(i).OwnerId = usr.Id;
    }
    //will throw on any limits issues
    List<Database.SaveResult> results = Database.update(cases, true);
    System.assertEquals(results.size() > 0, true);

    Test.stopTest();
  }
}
