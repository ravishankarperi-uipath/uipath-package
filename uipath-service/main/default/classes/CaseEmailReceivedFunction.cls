/**
 * Sets IsClosed_NotifyOnMail to TRUE after Closed Email is sent.
 */
public class CaseEmailReceivedFunction implements SObjectToSObjectFunction {
  public CaseEmailReceivedFunction(List<Case> cases) {
  }

  public SObject apply(Case record) {
    record.Customer_Contact__c = false;
    return record;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  public static void deriveCustomerContact(List<SObject> Records, Map<Id, SObject> existingRecords) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.No_of_Emails_Received__c },
      Records,
      existingRecords
    );

    Collection.of(Records)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.AcademyRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.ServiceRequestRecordType
            }
          )
      )
      .mapAll(new CaseEmailReceivedFunction(Records));
  }
}
