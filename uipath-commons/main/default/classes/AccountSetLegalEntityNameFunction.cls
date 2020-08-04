/**
 * Sets Legal Entity Name on each Account. Uses recordType to determine Legal Entity Name
 */
public class AccountSetLegalEntityNameFunction implements SObjectToSObjectFunction {
  public AccountSetLegalEntityNameFunction() {
  }

  public SObject apply(Account acc) {
    if (
      acc.Legal__c == null &&
      (acc.RecordTypeId ==
      AccountMetadata.getAccountRecordTypeId('Partner_Prospect') ||
      acc.RecordTypeId == AccountMetadata.getAccountRecordTypeId('Partner') ||
      acc.RecordTypeId == AccountMetadata.getAccountRecordTypeId('Academic') ||
      acc.RecordTypeId ==
      AccountMetadata.getAccountRecordTypeId('Customer_Prospect') ||
      acc.RecordTypeId == AccountMetadata.getAccountRecordTypeId('Customer'))
    ) {
      acc.Legal__c = acc.Name;
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  /**
   * Sets Legal Entity Name on Account
   * If Legal Entity Name is empty AND
   * Record Type is Academic, Partner, Customer, Customer Prospect OR Partner Prospect
   */
  public static void deriveLegalEntityNameOnInsert(List<Account> records) {
    Collection.of(records)
      .mapSome(
        Match.field(Account.RecordTypeId).hasValue(),
        new AccountSetLegalEntityNameFunction()
      );
  }
}
