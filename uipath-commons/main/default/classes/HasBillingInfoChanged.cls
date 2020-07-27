public class HasBillingInfoChanged implements SObjectPredicate {
    Map<Id, SObject> changedRecords = new Map<Id, SObject>();
  
    public HasBillingInfoChanged(
      Set<Schema.SObjectField> fieldTokens,
      List<SObject> records,
      Map<Id, SObject> existingRecords
    ) {
      for (SObject newRecord : Records) {
        Id recordId = (Id) newRecord.get('Id');
        if (existingRecords == null || !existingRecords.containsKey(recordId)) {
            for (Schema.SObjectField fieldToken : fieldTokens) {
                if (fieldToken == 'BillingCountry'){
                    if(newRecord.get(fieldToken) == 'United States' ||
                    newRecord.get(fieldToken) == 'China' ||
                    newRecord.get(fieldToken) == 'Australia' ||
                    newRecord.get(fieldToken) == 'Brazil' ||
                    newRecord.get(fieldToken) == 'Canada' ||
                    newRecord.get(fieldToken) == 'United Kingdom' ||
                    newRecord.get(fieldToken) == 'Ireland' ||
                    newRecord.get(fieldToken) == 'India' ||
                    newRecord.get(fieldToken) == 'Italy' ||
                    newRecord.get(fieldToken) == 'Mexico'){
                      changedRecords.put(newRecord.Id, newRecord);
                      break; // prevents the records from being added multiple times
                    }
                } 
                else if (fieldToken == Billing_State_Text_D_B__c){
                    if (newRecord.get(fieldToken) != null)
                    changedRecords.put(newRecord.Id, newRecord);
                    break; // prevents the records from being added multiple times
                }
              }
            continue;
        }
        SObject oldRecord = existingRecords.get(recordId);
        for (Schema.SObjectField fieldToken : fieldTokens) {
          if (fieldToken == 'BillingCountry' && oldRecord.get(fieldToken) != newRecord.get(fieldToken)){
              if(newRecord.get(fieldToken) == 'United States' ||
              newRecord.get(fieldToken) == 'China' ||
              newRecord.get(fieldToken) == 'Australia' ||
              newRecord.get(fieldToken) == 'Brazil' ||
              newRecord.get(fieldToken) == 'Canada' ||
              newRecord.get(fieldToken) == 'United Kingdom' ||
              newRecord.get(fieldToken) == 'Ireland' ||
              newRecord.get(fieldToken) == 'India' ||
              newRecord.get(fieldToken) == 'Italy' ||
              newRecord.get(fieldToken) == 'Mexico'){
                changedRecords.put(newRecord.Id, newRecord);
                break; // prevents the records from being added multiple times
              }
          } 
          else if (oldRecord.get(fieldToken) != newRecord.get(fieldToken)) {
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
  