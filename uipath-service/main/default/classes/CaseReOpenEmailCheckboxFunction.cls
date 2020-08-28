/**
 * Sets IsClosed_NotifyOnMail to TRUE after Closed Email is sent.
 */
public class CaseReOpenEmailCheckboxFunction implements SObjectToSObjectFunction {
  
    public CaseReOpenEmailCheckboxFunction(List<Case> cases) {
    }
  
    public SObject apply(Case record) {
      record.IsClosed_NotifyOnMail__c = TRUE;
      return record;
    }
  
    public SObject apply(SObject record) {
      return apply((Case) record);
    }
  
    public static void deriveCheckboxOnUpdate(List<Case> records) {

        SObjectPredicate hasChanged = new HasRecordChanged(
            new Set<SObjectField>{ Case.No_of_Emails_Received__c },
            cases,
            existingCases
          );

      Collection.of(accounts).filter(hasCountryChanged)
      .mapAll(new CaseReOpenEmailCheckboxFunction(records));

    }
  }
  