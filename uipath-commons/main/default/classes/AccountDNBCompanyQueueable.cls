/**
 * TODO REWRITE
 * this code was just moved here from the sync Trigger context into a Queueable Context.
 * Needs to be rewritten entirely
 */
public with sharing class AccountDNBCompanyQueueable extends AbstractQueueable {
    private final List<SObject> accountsLst;
    private final Map<Id, SObject> oldAccountsMap;

    public AccountDNBCompanyQueueable(
            List<SObject> accountsLst,
            Map<Id, SObject> oldAccountsMap
    ) {
        super('AccountDNBCompanyQueueable');
        this.accountsLst = accountsLst;
        this.oldAccountsMap = oldAccountsMap;
    }

    public override void work() {
        this.processDNBCompany(this.accountsLst, oldAccountsMap);
    }


  /**
   * TODO REWRITE
   * @DESCRIPTION: Process mapped D&B Company, create an address record for D&B address
   * @AUTHOR: SV - Slalom Consulting
   */
  private void processDNBCompany(List<SObject> accountList, Map<Id, SObject> oldAccountsMap) {

    List<Address__c> addressList = new List<Address__c>();
    Set<Id> addressHasBeenAddedFor = new Set<Id>();

    List<String> AvailableCountryStates = new List<String>();

    Schema.DescribeFieldResult stateResult = Address__c.State__c.getDescribe();
    List<Schema.PicklistEntry> statePLE = stateResult.getPicklistValues();
    for (Schema.PicklistEntry entry : statePLE) {
        AvailableCountryStates.add(entry.getValue());
    }


    for (Account acc : (List<Account>) accountList) {
      Account oldAccount = (Account) oldAccountsMap.get(acc.Id);

      //Only run the first time the D&B account/address is set
      if (
        String.IsNotBlank(acc.DnB_Country__c) &&
        String.IsBlank(oldAccount.DnB_Country__c)
      ) {
        if (addressHasBeenAddedFor.contains(acc.Id)) {
          //SFSL-827
          continue;
        }

        //Mapped D&B Company has changed. Create an address record based on D&B details and mark it as primary billing
        Address__c address = new Address__c();
        address.Account__c = acc.Id;
        address.Primary_Billing__c = true;
        address.Primary_Shipping__c = true;

        address.D_B_Address__c = true;

        //if D&B country is different from Country__c, data steward needs to fix data manually
        address.Country__c = acc.DnB_Country__c;

        //D&B street is 255 characters. On address object we have street 1 (150 characters) and street 2 (105 characters)
        if (String.IsNotBlank(acc.DnB_Street__c)) {
          address.Street_Line_1__c = acc.DnB_Street__c.left(150);
          if (acc.DnB_Street__c.length() > 150) {
            address.Street_Line_2__c = acc.DnB_Street__c.substring(
              150,
              acc.DnB_Street__c.length()
            );
          }
        }
        address.City__c = acc.DnB_City__c;
        address.Zip_Postal_Code__c = acc.DnB_Zip_Postal_Code__c;

        if (AvailableCountryStates.Contains(acc.DnB_State_Province__c)) {
          address.State__c = acc.DnB_State_Province__c;
        }

        address.RecordTypeId = Utilities.getRecordTypeId(
          Constants.ADDRESS_RECORD_TYPE_LOCKDOWN,
          'Address__c'
        );

        addressList.add(address);
        addressHasBeenAddedFor.add(acc.Id);
      }
    }
    insert addressList;
  }
}