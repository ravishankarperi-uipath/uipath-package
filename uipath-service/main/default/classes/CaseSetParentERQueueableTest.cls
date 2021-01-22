@isTest
private class CaseSetParentERQueueableTest {
  @IsTest
  private static void testDeriveParentEROnInsert() {
    Id parentId = fflib_IDGenerator.generate(Case.SObjectType);
    Id childId = fflib_IDGenerator.generate(Case.SObjectType);
    Id engagementRecordTypeID = CaseMetadata.EngagementRequestRecordType;

    Case parent = new Case(
      Id = parentId,
      Subject = 'Parent',
      RecordTypeId = engagementRecordTypeID,
      Status = 'New',
      Has_ER__c = false
    );
    Case child = new Case(
      Id = childId,
      ParentId = parentId,
      Subject = 'Child',
      RecordTypeId = engagementRecordTypeID,
      Status = 'New'
    );
    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ child });

    fflib_SObjectDomain.triggerHandler(Cases.class);
    System.assertEquals(false, parent.Has_ER__c);
  }

  @isTest
  private static void setParentERQueueable() {
    Id engagementRecordTypeID = CaseMetadata.EngagementRequestRecordType;

    Case parent = new Case(
      Subject = 'Parent',
      RecordTypeId = engagementRecordTypeID,
      Status = 'New',
      Has_ER__c = false
    );
    insert parent;

    Case child = new Case(
      Subject = 'Child',
      RecordTypeId = engagementRecordTypeID,
      Status = 'New',
      ParentId = parent.Id
    );
    insert child;

    CaseSetParentERQueueable setParentERQueueable = new CaseSetParentERQueueable(new List<Case>{ child });
    setParentERQueueable.execute(null);

    Case updatedParent = [SELECT Id, Has_ER__c FROM Case WHERE Id = :parent.Id LIMIT 1];
    System.assertEquals(true, updatedParent.Has_ER__c);
  }
}
