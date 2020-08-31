@isTest
private class SetParentERQueueableTest {
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

    SetParentERQueueable setParentERQueueable = new SetParentERQueueable(new List<Case>{ child });
    setParentERQueueable.execute(null);

    Case updatedParent = [SELECT Id, Has_ER__c FROM Case WHERE Id = :parent.Id LIMIT 1];
    System.assertEquals(true, updatedParent.Has_ER__c);
  }
}
