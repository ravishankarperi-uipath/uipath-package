public class HasRecordChanged implements SObjectPredicate {
  Map<Id, SObject> changedRecords = new Map<Id, SObject>();

  public HasRecordChanged(
    Set<Schema.SObjectField> fieldTokens,
    List<SObject> records,
    Map<Id, SObject> existingRecords
  ) {
    for (SObject newRecord : Records) {
      Id recordId = (Id) newRecord.get('Id');
      if (existingRecords == null || !existingRecords.containsKey(recordId)) {
        continue;
      }
      SObject oldRecord = existingRecords.get(recordId);
      for (Schema.SObjectField fieldToken : fieldTokens) {
        if (oldRecord.get(fieldToken) != newRecord.get(fieldToken)) {
          changedRecords.put(newRecord.Id, newRecord);
          break; // prevents the records from being added multiple times
        }
      }
    }
  }

  public Boolean apply(SObject record) {
    return changedRecords.containsKey(record.Id);
  }
}
