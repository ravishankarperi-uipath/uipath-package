/**
 * Service to delegate address processing from Domain
 * Tests for this are embedded within the domain tests
 */
public without sharing class AccountMapDnBAddressFunction implements SObjectToSObjectFunction {
  private Boolean isUpdateMode = false;

  public AccountMapDnBAddressFunction(Boolean isUpdateMode) {
    this.isUpdateMode = isUpdateMode;
  }

  public SObject apply(Account acc) {
    if (isUpdateMode) {
      copyDnBAddressToStandardAddress(acc);
    } else {
      copyCountryToBillingCountry(acc);
      deriveBillingCountryFromCode(acc);

      if (String.isNotBlank(acc.DnB_Country__c)) {
        //These 2 fields are only set on insert
        acc.Country__c = acc.DnB_Country__c;
        acc.BillingCountry = acc.DnB_Country__c;

        copyDnBAddressToStandardAddress(acc);
      }
    }
    return acc;
  }

  public SObject apply(SObject record) {
    return apply((Account) record);
  }

  public static void deriveBillingCountryFromCode(Account account) {
    Map<String, String> codeAndCountryMap = AccountMetadata.CountryCodes;
    if (String.isBlank(account.BillingCountry) && String.isNotBlank(account.BillingCountryCode)) {
      //In case of lead conversion, country code is available on before insert, but country is not available until after insert
      //Fix that here, so that we can use country for address logic
      account.BillingCountry = codeAndCountryMap.get(account.BillingCountryCode);
    }
  }

  public static void copyCountryToBillingCountry(Account account) {
    Map<String, String> countryNameAndCodeMap = AccountMetadata.CountryNameAndCodes;
    if (String.isBlank(account.BillingCountry) && String.isNotBlank(account.Country__c)) {
      account.BillingCountryCode = countryNameAndCodeMap.get(account.Country__c);
    }
  }

  public static void copyDnBAddressToStandardAddress(Account account) {
    account.BillingCountry = account.DnB_Country__c;
    account.BillingStreet = account.DnB_Street__c;
    account.BillingCity = account.DnB_City__c;
    if (String.isNotBlank(account.DnB_Zip_Postal_Code__c)) {
      if (account.BillingCountry == 'United States') {
        account.BillingPostalCode = account.DnB_Zip_Postal_Code__c.left(5);
      } else {
        account.BillingPostalCode = account.DnB_Zip_Postal_Code__c;
      }
    }

    if (
      AccountMetadata.AvailableCountryStates.Contains(account.DnB_State_Province__c) &&
      (isStateSupportedForCountry(account.BillingCountry))
    ) {
      account.BillingState = account.DnB_State_Province__c;
    } else {
      account.DnB_State_Province__c = '';
    }

    //Default shipping address to billing address on insert
    account.ShippingCountry = account.BillingCountry;
    account.ShippingState = account.BillingState;
    account.ShippingStreet = account.BillingStreet;
    account.ShippingCity = account.BillingCity;
    account.ShippingPostalCode = account.BillingPostalCode;
  }

  public static Boolean isStateSupportedForCountry(String country) {
    return country == 'United States' ||
      country == 'China' ||
      country == 'Australia' ||
      country == 'Brazil' ||
      country == 'Canada' ||
      country == 'United Kingdom' ||
      country == 'Ireland' ||
      country == 'India' ||
      /* country == 'Italy' || */
      country == 'Mexico';
  }

  /**
   * Copies D&B Address Fields into Standard Address Fields (Billing and Shipping).
   * For US, only first 5 characters of Postal code is derived Only some countries are allowed to have BillingState set
   */
  public static void deriveAddressFieldsOnInsert(List<Account> records) {
    Collection.of(records).mapAll(new AccountMapDnBAddressFunction(false));
  }

  /**
   * On Account Update, Copies D&B Address Fields into Standard Address Fields (Billing and Shipping).
   * For US, only first 5 characters of Postal code is derived Only some countries are allowed to have BillingState set
   */
  public static void deriveAddressFieldsOnUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasCountryChanged = new HasRecordChanged(
      new Set<SObjectField>{ Account.DnB_Country__c, Account.DnB_State_Province__c },
      accounts,
      existingAccounts
    );

    Collection.of(accounts).filter(hasCountryChanged).mapAll(new AccountMapDnBAddressFunction(true));
  }
}
