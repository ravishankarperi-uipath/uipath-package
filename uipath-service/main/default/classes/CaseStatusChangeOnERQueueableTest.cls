@IsTest
public class CaseStatusChangeOnERQueueableTest {
  @TestSetup
  private static void makeData() {
    Id engagementRecordTypeId = CaseMetadata.EngagementRequestRecordType;
    Case parentCase = new Case(
      Subject = 'Parent',
      RecordTypeId = engagementRecordTypeId,
      Status = 'New',
      Description = 'Parent Case'
    );
    insert parentCase;
    Case childCase = new Case(
      ParentId = parentCase.Id,
      Subject = 'Child',
      RecordTypeId = engagementRecordTypeId,
      Status = 'New',
      Description = 'Child Case'
    );
    insert childCase;
  }

  @isTest
  private static void updateChildNotification_onERStatusChange() {
    Id engagementRecordTypeId = CaseMetadata.EngagementRequestRecordType;
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Case childCase = [
      SELECT Id, CaseNumber, Subject, RecordTypeId, Description, Status, ParentId
      FROM Case
      WHERE ParentId != null
      LIMIT 1
    ];

    Case updatedCase = new Case(
      Id = childCase.Id,
      ParentId = childCase.ParentId,
      Subject = 'Test',
      RecordTypeId = engagementRecordTypeId,
      Status = 'In Process'
    );

    new CaseStatusChangeOnERQueueable(new List<Case>{ updatedCase }).execute(null);
    Case parentCase = [SELECT Id, Status, Child_case_Updates_Notification__c FROM Case WHERE ParentId = null LIMIT 1];
    System.assertNotEquals(null, parentCase.Child_case_Updates_Notification__c, 'Child case status isupdated');
  }

  @isTest
  private static void updateChildNotification_onERFirstResponseChange() {
    Id engagementRecordTypeId = CaseMetadata.EngagementRequestRecordType;
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Case childCase = [
      SELECT Id, CaseNumber, Subject, RecordTypeId, Description, Status, ParentId
      FROM Case
      WHERE ParentId != null
      LIMIT 1
    ];

    Case updatedCase = new Case(
      Id = childCase.Id,
      ParentId = childCase.ParentId,
      Subject = 'Test',
      RecordTypeId = engagementRecordTypeId,
      First_Response__c = 'First response received.'
    );

    new CaseFirstResponseOnERQueueable(new List<Case>{ updatedCase }).execute(null);
    Case parentCase = [SELECT Id, Status, Child_case_Updates_Notification__c FROM Case WHERE ParentId = null LIMIT 1];
    System.assertNotEquals(null, parentCase.Child_case_Updates_Notification__c, 'Child First Response is updated');
  }

  @isTest
  private static void updateChildNotification_onEROwnerChange() {
    Id engagementRecordTypeId = CaseMetadata.EngagementRequestRecordType;
    Id userId = fflib_IDGenerator.generate(User.SObjectType);
    Case childCase = [
      SELECT Id, CaseNumber, Subject, RecordTypeId, Description, Status, ParentId
      FROM Case
      WHERE ParentId != null
      LIMIT 1
    ];

    Case updatedCase = new Case(
      Id = childCase.Id,
      ParentId = childCase.ParentId,
      Subject = 'Test',
      RecordTypeId = engagementRecordTypeId,
      OwnerId = userId
    );

    new CaseOwnerChangeOnERQueueable(new List<Case>{ updatedCase }).execute(null);
    Case parentCase = [SELECT Id, Status, Child_case_Updates_Notification__c FROM Case WHERE ParentId = null LIMIT 1];
    System.assertNotEquals(null, parentCase.Child_case_Updates_Notification__c, 'Child Owner is updated');
  }

  @isTest
  private static void updateChildNotification_onResolutionChange() {
    Id engagementRecordTypeId = CaseMetadata.EngagementRequestRecordType;
    Id userId = fflib_IDGenerator.generate(User.SObjectType);
    Case childCase = [
      SELECT Id, CaseNumber, Subject, RecordTypeId, Description, Status, ParentId
      FROM Case
      WHERE ParentId != null
      LIMIT 1
    ];

    Case updatedCase = new Case(
      Id = childCase.Id,
      ParentId = childCase.ParentId,
      Subject = 'Test',
      RecordTypeId = engagementRecordTypeId,
      Resolution_from_L2__c = 'Resolution is now updated'
    );

    new CaseL2ResolutionChangeOnERQueueable(new List<Case>{ updatedCase }).execute(null);
    Case parentCase = [SELECT Id, Status, Child_case_Updates_Notification__c FROM Case WHERE ParentId = null LIMIT 1];
    System.assertNotEquals(null, parentCase.Child_case_Updates_Notification__c, 'Child Resultion from L2 is changed');
  }
}
