/**
 * Responsibility: Populate Territory fields Geo, Region, Area on Account
 *
 */
public without sharing class AccountTerritoryService {
  /**
   * Populate Territory fields Geo, Region, Area.
   * Uses Custom Metadata types to derive Territory based on Account Industry and Address fields.
   * For USA => Industry, State and Zipcode are used to map  Territory
   * For India and Japan => State and Country are used to map  Territory
   * For Rest of the world => only country is used to map Territory
   * @param accounts
   */
  public static void deriveTerritoryFields(List<Account> accounts) {
    SObjectIndex usaIndustriesByName = AccountMetadata.getUsaIndustriesByName();
    SObjectIndex statesByCodeAndCountry = AccountMetadata.getStatesByCodeAndCountry();
    SObjectIndex usaZipCodesIndex = AccountMetadata.getUsaZipCodesForAccounts(accounts);
    SObjectIndex countriesByCountryCode = AccountMetadata.getCountriesByCountryCode();

    Collection.of(accounts)
      .filter(new IsAccountEligibleForTerritoryAllocation())
      .mapSome(
        isAccountCountryUnitedStates(),
        new AssignTerritoryForUnitedStates(usaIndustriesByName, statesByCodeAndCountry, usaZipCodesIndex)
      )
      .mapSome(
        isAccountCountryJapanIndia(),
        new AssignTerritoryForIndiaJapan(statesByCodeAndCountry, countriesByCountryCode)
      )
      .mapSome(isAccountCountryRestOfWorld(), new AssignTerritoryForRestOfWorld(countriesByCountryCode));
  }

  private static FieldsMatch isAccountCountryJapanIndia() {
    return Match.field(Account.BillingCountryCode).isIn(new Set<String>{ 'IN', 'JP' });
  }

  private static FieldsMatch isAccountCountryRestOfWorld() {
    return Match.field(Account.BillingCountryCode).notIn(new Set<String>{ 'IN', 'JP', 'US' });
  }

  public class IsAccountEligibleForTerritoryAllocation implements SObjectPredicate {
    private Boolean apply(Account acc) {
      return !acc.Ignore_Territory_Assignment__c && String.isNotBlank(acc.BillingCountryCode);
    }

    public Boolean apply(SObject record) {
      return apply((Account) record);
    }
  }

  private static FieldsMatch isAccountCountryUnitedStates() {
    return Match.field(Account.BillingCountryCode).equals('US');
  }

  private static void copyTerritoryFields(Account acc, SObject sobj) {
    if (sobj == null)
      return;

    acc.Geo__c = (String) sobj.get('Region__c');
    acc.Region__c = (String) sobj.get('Territory__c');
    acc.Area__c = (String) sobj.get('Area__c');
  }

  private class AssignTerritoryForUnitedStates implements SObjectToSObjectFunction {
    SObjectIndex usaIndustriesByName;
    SObjectIndex statesByCodeAndCountry;
    SObjectIndex usaZipCodesIndex;

    public AssignTerritoryForUnitedStates(
      SObjectIndex usaIndustriesByName,
      SObjectIndex statesByCodeAndCountry,
      SObjectIndex usaZipCodesIndex
    ) {
      this.usaIndustriesByName = usaIndustriesByName;
      this.statesByCodeAndCountry = statesByCodeAndCountry;
      this.usaZipCodesIndex = usaZipCodesIndex;
    }

    private SObject apply(Account acc) {
      USA_Industry__mdt accountIndustry = AccountMetadata.getAccountIndustry(usaIndustriesByName, acc);
      USA_States__mdt accountState = AccountMetadata.getAccountState(statesByCodeAndCountry, acc);
      UsaZipCodes__mdt accountZipcode = AccountMetadata.getAccountZipcode(usaZipCodesIndex, acc);
      acc.Geo__c = 'AMER';

      SObject territorySource = null;
      if (accountIndustry != null) {
        territorySource = accountIndustry;
      } else if (accountState != null) {
        territorySource = accountState;
      } else if (accountZipcode != null) {
        territorySource = accountZipcode;
      }

      copyTerritoryFields(acc, territorySource);
      return acc;
    }

    public SObject apply(SObject record) {
      return apply((Account) record);
    }
  }

  private class AssignTerritoryForIndiaJapan implements SObjectToSObjectFunction {
    SObjectIndex statesByCodeAndCountry;
    SObjectIndex countriesByCountryCode;

    public AssignTerritoryForIndiaJapan(SObjectIndex statesByCodeAndCountry, SObjectIndex countriesByCountryCode) {
      this.statesByCodeAndCountry = statesByCodeAndCountry;
      this.countriesByCountryCode = countriesByCountryCode;
    }

    private SObject apply(Account acc) {
      USA_States__mdt accountState = AccountMetadata.getAccountState(statesByCodeAndCountry, acc);
      ROW_Country__mdt accountCountry = AccountMetadata.getAccountCountry(countriesByCountryCode, acc);

      SObject territorySource = null;

      if (accountState != null) {
        territorySource = accountState;
      } else {
        if (accountCountry != null) {
          territorySource = accountCountry;
        }
      }
      copyTerritoryFields(acc, territorySource);
      return acc;
    }

    public SObject apply(SObject record) {
      return apply((Account) record);
    }
  }

  private class AssignTerritoryForRestOfWorld implements SObjectToSObjectFunction {
    SObjectIndex countriesByCountryCode;

    public AssignTerritoryForRestOfWorld(SObjectIndex countriesByCountryCode) {
      this.countriesByCountryCode = countriesByCountryCode;
    }

    private SObject apply(Account acc) {
      ROW_Country__mdt accountCountry = AccountMetadata.getAccountCountry(countriesByCountryCode, acc);
      if (accountCountry != null) {
        copyTerritoryFields(acc, accountCountry);
      }
      return acc;
    }

    public SObject apply(SObject record) {
      return apply((Account) record);
    }
  }

  /**
   * Update Account Territory fields Geo, Region, Area.
   * Uses Custom Metadata types to derive Territory based on Account Industry and Address fields.
   * For USA => Industry, State and Zipcode are used to map  Territory
   * For India and Japan => State and Country are used to map  Territory
   * For Rest of the world => only country is used to map Territory
   */
  public static void deriveTerritoryFieldsOnUpdate(List<Account> accounts, Map<Id, SObject> existingAccounts) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.BillingCountryCode,
        Account.BillingStateCode,
        Account.BillingPostalCode,
        Account.Industry,
        Account.Geo__c,
        Account.Region__c,
        Account.Area__c
      },
      accounts,
      existingAccounts
    );
    List<Account> changedAccounts = Collection.of(accounts).filter(hasChanged).asList();

    if (!changedAccounts.isEmpty()) {
      AccountTerritoryService.deriveTerritoryFields(changedAccounts);
    }
  }
}
