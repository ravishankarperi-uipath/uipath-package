public with sharing class AccountConvertAcademic {
  /**
   * On Account Update, Converts Academic RT to Customer Prospect RT if Account has open opportunities
   * TODO move this to Opty closed logic instead of reprocessing on Account
   */
  public static void convertAcademicAccountOnUpdate(
    List<Account> accounts,
    Map<Id, SObject> existingAccounts
  ) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{
        Account.RecordTypeId,
        Account.Has_Open_Opportunities__c
      },
      accounts,
      existingAccounts
    );

    List<Account> changedAccounts = Collection.of(accounts)
      .filter(hasChanged)
      .asList();

    if (!changedAccounts.isEmpty()) {
      convertAcademicAccount(changedAccounts);
    }
  }

  /**
   * Convert Academic RT to Customer Prospect if has open opportunities
   * *Org-cleanup : Process Builder - Academic Alliance Account - Update Record Type
   *  TODO : Send push notification : Academic Alliance
   */
  public static void convertAcademicAccount(List<Account> accList) {
    Id academicRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Academic')
      .getRecordTypeId();
    Id customerProspectRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Customer_Prospect')
      .getRecordTypeId();

    Collection.of(accList)
      .filter(
        Match.field(Account.RecordTypeId)
          .equals(academicRT)
          .also(Account.Has_Open_Opportunities__c)
          .greaterThan(0)
      )
      .mapAll(
        CopyFields.fromRecord(new Account(RecordTypeId = customerProspectRT))
      );
  }
}
