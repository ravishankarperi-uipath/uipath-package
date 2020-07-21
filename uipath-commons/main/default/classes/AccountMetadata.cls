/**
 * Responsibility: Lazy loads Account related metadata and provides a single shared static cached access point
 */
public without sharing class AccountMetadata {
  public static List<USA_States__mdt> States {
    get {
      if (States == null) {
        States = [
          SELECT
            Label,
            DeveloperName,
            Region__c,
            Billing_State_Code__c,
            Area__c,
            Territory__c,
            Country__c
          FROM USA_States__mdt
        ];
      }
      return States;
    }
    set;
  }

  public static List<ROW_Country__mdt> Countries {
    get {
      if (Countries == null) {
        Countries = [
          SELECT Country_Code__c, Region__c, Area__c, Territory__c
          FROM ROW_Country__mdt
        ];
      }
      return Countries;
    }
    set;
  }

  public static List<USA_Industry__mdt> Industries {
    get {
      if (Industries == null) {
        Industries = [
          SELECT Region__c, Industry__c, Area__c, Territory__c
          FROM USA_Industry__mdt
        ];
      }
      return Industries;
    }
    set;
  }

  public static List<Country_Subsidiary_Mapping__mdt> SubsidiaryCountryMap {
    get {
      if (SubsidiaryCountryMap == null) {
        SubsidiaryCountryMap = [
          SELECT MasterLabel, Country_Code__c, Subsidiary__c
          FROM Country_Subsidiary_Mapping__mdt
        ];
      }
      return SubsidiaryCountryMap;
    }
    set;
  }

  public static List<String> AvailableCountryStates {
    get {
      if (AvailableCountryStates == null) {
        AvailableCountryStates = new List<String>();

        Schema.DescribeFieldResult stateResult = Address__c.State__c.getDescribe();
        List<Schema.PicklistEntry> statePLE = stateResult.getPicklistValues();

        for (Schema.PicklistEntry entry : statePLE) {
          AvailableCountryStates.add(entry.getValue());
        }
      }
      return AvailableCountryStates;
    }
    set;
  }

  public static Map<String, String> CountryCodes {
    get {
      if (CountryCodes == null) {
        CountryCodes = new Map<String, String>();

        //Retrieve Country Codes
        Schema.DescribeFieldResult countryCodeResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> countryPLE = countryCodeResult.getPicklistValues();
        for (Schema.PicklistEntry entry : countryPLE) {
          CountryCodes.put(entry.getValue(), entry.getLabel());
        }
      }
      return CountryCodes;
    }
    set;
  }

  public static Id getAccountRecordTypeId(String recordTypeName) {
    Id RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();
    return RTId;
  }

  public static SObjectIndex getCountriesByCountryCode() {
    SObjectIndex countriesByCountryCode = new SObjectIndex(
        new List<String>{ 'Country_Code__c' }
      )
      .putAll(AccountMetadata.Countries);
    return countriesByCountryCode;
  }

  public static SObjectIndex getUsaZipCodesForAccounts(List<Account> accounts) {
    List<String> zipCodes = Collection.of(accounts)
      .pluckStrings(Account.BillingPostalCode);

    List<UsaZipCodes__mdt> usaZipCodes = [
      SELECT Postal_Code__c, Region__c, Area__c, Territory__c
      FROM UsaZipCodes__mdt
      WHERE Postal_Code__c IN :zipCodes
    ];
    SObjectIndex usaZipCodesIndex = new SObjectIndex(
        new List<String>{ 'Postal_Code__c' }
      )
      .putAll(usaZipCodes);
    return usaZipCodesIndex;
  }

  public static SObjectIndex getStatesByCodeAndCountry() {
    SObjectIndex statesByCodeAndCountry = new SObjectIndex(
        new List<String>{ 'Billing_State_Code__c', 'Country__c' }
      )
      .putAll(AccountMetadata.States);
    return statesByCodeAndCountry;
  }

  public static SObjectIndex getUsaIndustriesByName() {
    SObjectIndex usaIndustriesByName = new SObjectIndex(
        new List<String>{ 'Industry__c' }
      )
      .putAll(AccountMetadata.Industries);
    return usaIndustriesByName;
  }

  public static ROW_Country__mdt getAccountCountry(
    SObjectIndex countriesByCountryCode,
    Account acc
  ) {
    ROW_Country__mdt accountCountry = (ROW_Country__mdt) countriesByCountryCode.get(
      new ROW_Country__mdt(Country_Code__c = acc.BillingCountryCode)
    );
    return accountCountry;
  }

  public static UsaZipCodes__mdt getAccountZipcode(
    SObjectIndex usaZipCodesIndex,
    Account acc
  ) {
    UsaZipCodes__mdt accountZipcode = (UsaZipCodes__mdt) usaZipCodesIndex.get(
      new UsaZipCodes__mdt(Postal_Code__c = acc.BillingPostalCode)
    );
    return accountZipcode;
  }

  public static USA_States__mdt getAccountState(
    SObjectIndex usaStatesByCodeAndCountry,
    Account acc
  ) {
    USA_States__mdt accountState = (USA_States__mdt) usaStatesByCodeAndCountry.get(
      new USA_States__mdt(
        Billing_State_Code__c = acc.BillingStateCode,
        Country__c = acc.BillingCountryCode
      )
    );
    return accountState;
  }

  public static USA_Industry__mdt getAccountIndustry(
    SObjectIndex usaIndustriesByName,
    Account acc
  ) {
    USA_Industry__mdt accountIndustry = (USA_Industry__mdt) (usaIndustriesByName.get(
      acc.Industry
    ));
    return accountIndustry;
  }

  public static Map<String, String> getCountrySubsidiaryMap() {
    Map<String, String> countrySubsidiaryMap = new Map<String, String>();
    Map<String, String> countryCodeSubsidiaryMap = new Map<String, String>();
    for (
      Country_Subsidiary_Mapping__mdt mapping : AccountMetadata.SubsidiaryCountryMap
    ) {
      countrySubsidiaryMap.put(
        mapping.MasterLabel.toLowerCase(),
        mapping.Subsidiary__c
      );
      countryCodeSubsidiaryMap.put(
        mapping.Country_Code__c,
        mapping.Subsidiary__c
      );
    }
    return countrySubsidiaryMap;
  }
}
