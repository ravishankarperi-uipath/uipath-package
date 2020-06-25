public with sharing class TestSupportObject extends fflib_SObjectDomain implements ITestSupportObjects {
  public static ITestSupportObjects newInstance(List<TestSupportObject__c> recordList) {
    return (ITestSupportObjects) TestApplication.Domain.newInstance(recordList);
  }

  public static ITestSupportObjects newInstance(Set<Id> recordIdSet) {
    return (ITestSupportObjects) TestApplication.Domain.newInstance(recordIdSet);
  }

  public TestSupportObject(List<TestSupportObject__c> sObjectList) {
    super(sObjectList);
  }


  public class Constructor implements fflib_SObjectDomain.IConstructable
  {
    public fflib_SObjectDomain construct(List<SObject> sObjectList)
    {
      return new TestSupportObject(sObjectList);
    }
  }


  public override void onAfterInsert() {
    QueueableWrapper.enqueue(new QueueableWrapperTest.TestQueueable());

  }
}
