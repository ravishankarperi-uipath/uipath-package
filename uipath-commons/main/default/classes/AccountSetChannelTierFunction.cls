/**
 * Sets Channel Tier on each Account. Uses recordType to determine Channel Tier
 */
public class AccountSetChannelTierFunction implements SObjectToSObjectFunction {
  private Id partnerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Partner_Prospect')
    .getRecordTypeId();
  private Id partnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Partner')
    .getRecordTypeId();

  public AccountSetChannelTierFunction() {
  }

  public SObject apply(Account acc) {
    if (acc.RecordTypeId == partnerProspectRT || acc.RecordTypeId == partnerRT) {
      acc.Channel_Tier__c = 'Reseller';
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  /**
   * On Account Insert, Derives Channel tier based on Account Record Type
   */
  public static void deriveChannelTierOnInsert(List<Account> records) {
    Collection.of(records).mapSome(Match.field(Account.RecordTypeId).hasValue(), new AccountSetChannelTierFunction());
  }
}
