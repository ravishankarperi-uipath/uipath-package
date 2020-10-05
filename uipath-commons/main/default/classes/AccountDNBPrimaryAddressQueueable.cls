/**
 * Updates Primary address with all DnB address details
 */
public with sharing class AccountDNBPrimaryAddressQueueable extends AbstractQueueable {
  private final List<SObject> accountsLst;
  private final Map<Id, SObject> oldAccountsMap;

  public AccountDNBPrimaryAddressQueueable(List<SObject> accountsLst, Map<Id, SObject> oldAccountsMap) {
    super('AccountDNBPrimaryAddressQueueable');
    this.accountsLst = accountsLst;
    this.oldAccountsMap = oldAccountsMap;
  }

  public override void work() {
    this.processDNBAddress(this.accountsLst, oldAccountsMap);
  }

  /**

     */
  private void processDNBAddress(List<SObject> accountList, Map<Id, SObject> oldAccountsMap) {
    Map<Id, Address__c> addressMap = getAddresses(accountList);

    List<Address__c> addressToUpdate = new List<Address__c>();
    for (Account acc : (List<Account>) accountList) {
      Account oldAccount = (Account) oldAccountsMap.get(acc.Id);
      if (addressMap.containsKey(acc.Id)) {
        Address__c address = addressMap.get(acc.Id);
        //Only run the first time the D&B account/address is set
        Address__c comlpetedaddress = null;
        if (String.IsNotBlank(acc.DnB_City__c) && String.IsBlank(oldAccount.DnB_City__c)) {
          comlpetedaddress = populateAddress(acc, address);
          comlpetedaddress.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName()
            .get(CommonsConstants.ADDRESS_RECORD_TYPE_LOCKDOWN)
            .getRecordTypeId();
        }

        if (comlpetedaddress != null)
          addressToUpdate.add(comlpetedaddress);
      }
    }
    update addressToUpdate;
  }

  private Address__c populateAddress(Account acc, Address__c address) {
    address.City__c = acc.DnB_City__c;
    if (String.IsNotBlank(acc.DnB_Street__c)) {
      if (String.IsBlank(address.State__c) && String.IsNotBlank(acc.DnB_State_Province__c)) {
        address.State__c = acc.DnB_State_Province__c;
      }
      address.Street_Line_1__c = acc.DnB_Street__c.left(150);
      if (acc.DnB_Street__c.length() > 150) {
        address.Street_Line_2__c = acc.DnB_Street__c.substring(150, acc.DnB_Street__c.length());
      }
    }
    if (String.IsNotBlank(acc.DnB_Zip_Postal_Code__c)) {
      address.Zip_Postal_Code__c = acc.DnB_Zip_Postal_Code__c;
      if (acc.DnB_Country__c == 'United States') {
        address.Zip_Postal_Code__c = (acc.DnB_Zip_Postal_Code__c).left(5);
      }
    }
    return address;
  }

  private Map<Id, Address__c> getAddresses(List<Account> accList) {
    Map<Id, Address__c> addressMap = new Map<Id, Address__c>();

    List<Address__c> addressList = [
      SELECT Id, Account__c, State__c, Street_Line_1__c, Street_Line_2__c, City__c, Zip_Postal_Code__c
      FROM Address__c
      WHERE Account__c IN :accList AND Primary_Billing__c = true AND City__c = null
    ];

    for (Address__c addr : addressList) {
      if (!addressMap.containsKey(addr.Account__c)) {
        addressMap.put(addr.Account__c, addr);
      }
    }
    return addressMap;
  }
  /**
   * create an address record for when an account is updated using D&B address
   * @param existingRecords
   */
  public static void updateAddressForDnBCompany(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.DnB_City__c, Account.DnB_Street__c, Account.DnB_Zip_Postal_Code__c },
      accounts,
      existingAccounts
    );
    List<Account> eligibleAccounts = (List<Account>) Collection.of(accounts)
      .filter(Match.field(Account.DnB_City__c).hasValue())
      .filter(hasChanged)
      .asList();

    if (!eligibleAccounts.isEmpty()) {
      AbstractQueueable.enqueue(new AccountDNBPrimaryAddressQueueable(eligibleAccounts, existingAccounts));
    }
  }
}
