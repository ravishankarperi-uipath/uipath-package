/**
 * @AUTHOR: Slalom Consulting
 * @DATE: 05/04/2019
 * @DESCRIPTION: This class is created to handle the "Sync Automation" for Dell Boomi Integration. It will be used by all the Salesforce Objects that would be
 *               integrated using Dell Boomi. It checks if the updates have been made to the synced records in Salesforce by user other than boomi integration user and
 *               flags it ready for integration by setting the "Sync Status" on that record to "Pending"
 */

public without sharing class IntegrationHandler {
  /**
   * @Description: Compare old and new object to see if certain fields have changed. If they have changed, then we set the Sync Status field on that object to pending.
   *               A workflow outbound message is created when the Sync Status field is pending and send to Dell Boomi.
   */
  public static void syncStatusAutomationProcess(
    Map<Id, SObject> oldObjects,
    List<SObject> newObjects
  ) {
    // Don't check for changes if the user making the change is an  Integration Profile user.
    Boolean integrationUser = isIntegrationUser(UserInfo.getProfileId());
    if (!integrationUser) {
      // We only want to check for changes when the object Sync Status is in a certain Status.
      // Status we want to ignore are in Custom meta data Integration Settings
      Set<String> syncStatuses = getExcludedStatuses();

      //Get a list of fields to check for changes.
      String sObjectName = newObjects[0].getSObjectType().getDescribe().name;

      List<Schema.FieldSetMember> fields;

      //The unlocked package has no dependencies with DNBOptimizer Package so needs a separate fieldset for testing
      if (Test.isRunningTest() && sObjectName == 'Account') {
        fields = readFieldSet(
          CommonsConstants.INTEGRATION_FIELDSET_NAME_TEST,
          sObjectName
        );
      } else {
        fields = readFieldSet(
          CommonsConstants.INTEGRATION_FIELDSET_NAME,
          sObjectName
        );
      }

      for (SObject newObj : newObjects) {
        String newObjectStatus = (String) newObj.get(
          CommonsConstants.INTEGRATION_SYNC_STATUS_FIELD
        );

        if (
          String.isNotEmpty(newObjectStatus) &&
          !syncStatuses.contains(newObjectStatus)
        ) {
          SObject oldObj = oldObjects.get(newObj.Id);

          for (Schema.FieldSetMember field : fields) {
            if (oldObj.get(field.fieldPath) != newObj.get(field.fieldPath)) {
              newObj.put(
                CommonsConstants.INTEGRATION_SYNC_STATUS_FIELD,
                CommonsConstants.ACC_SYNC_STATUS_PENDING
              );
              // No point carrying on, as a field has changed and we've already marked this object for Integration to pick up
              break;
            }
          }
        }
      }
    }
  }

  /**
   * @Description: Returns a list of excluded Sync Statuses. If the record has any of these Sync Status, then Sync Status should NOT be set to "Pending"
   */
  private static Set<String> getExcludedStatuses() {
    Integration_Setting__mdt integrationSetting = [
      SELECT Id, Excluded_Sync_Statuses__c
      FROM Integration_Setting__mdt
      LIMIT 1
    ];
    return new Set<String>(
      integrationSetting.Excluded_Sync_Statuses__c.split(',')
    );
  }

  /**
   * @Description: Returns a list of fields that need to be checked for any changes
   */
  private static List<Schema.FieldSetMember> readFieldSet(
    String fieldSetName,
    String ObjectName
  ) {
    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap()
      .get(fieldSetName);

    return fieldSetObj.getFields();
  }

  /**
   * @Description: Returns true if the user either has an integration profile or the Boomi Integration permission set
   */
  private static Boolean isIntegrationUser(ID userProfileId) {
    Boolean isIntegrationPermSetPresent = false;
    Boolean isIntegrationProfilePresent = false;

    //Check if logged in user has "Integration User" profile
    Profile currentUserProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE Id = :userProfileId
      LIMIT 1
    ];
    if (
      currentUserProfile != null &&
      currentUserProfile.Name == CommonsConstants.INTEGRATION_PROFILE_NAME
    ) {
      isIntegrationProfilePresent = true;
    }

    //Check if logged in user has "Integration User" permission set
    List<PermissionSetAssignment> currentUserPermSetLst = [
      SELECT Id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE AssigneeId = :Userinfo.getUserId()
    ];
    for (PermissionSetAssignment psa : currentUserPermSetLst) {
      if (
        psa.PermissionSet.Name ==
        CommonsConstants.BOOMI_INTEGRATION_PERMISSION_SET_NAME
      ) {
        isIntegrationPermSetPresent = true;
      }
    }

    return (isIntegrationProfilePresent || isIntegrationPermSetPresent)
      ? true
      : false;
  }

  /**
   * @Description: Updates the given accounts Validation status if the exiting status is Pending
   */
  public static void updateAccountValidationStatusToReadyForReview(
    Set<Id> idsToRetrieve
  ) {
    List<Account> lstAccounts = [
      SELECT id, Validation_Status__c
      FROM Account
      WHERE
        Id IN :idsToRetrieve
        AND Validation_Status__c = :CommonsConstants.ACC_SYNC_STATUS_PENDING
    ];

    for (Account acct : lstAccounts) {
      acct.Validation_Status__c = CommonsConstants.ACC_VALIDATION_STATUS_READY_FOR_REVIEW;
    }

    List<Address__c> addressesToUpdate = [
      SELECT id, Validation_Status__c, Account__c
      FROM Address__c
      WHERE
        Account__c IN :idsToRetrieve
        AND Validation_Status__c = :CommonsConstants.ACC_SYNC_STATUS_PENDING
    ];

    for (Address__c a : addressesToUpdate) {
      a.Validation_Status__c = CommonsConstants.ACC_VALIDATION_STATUS_READY_FOR_REVIEW;
    }

    update lstAccounts;
    update addressesToUpdate;
  }

  public static void callAccountSyncStatusIntegrationProcess(
    List<Account> accounts,
    Map<Id, SObject> existingAccounts
  ) {
    List<Account> validatedAccounts = Collection.of(accounts)
      .filter(
        Match.field(Account.Validation_Status__c)
          .equals(CommonsConstants.ACC_VALIDATION_STATUS_VALIDATED)
      )
      .asList();

    // Call the SyncStatusAutomation Process to check if the Account Updates can be flagged ready to sync to NetSuite
    if (!validatedAccounts.isEmpty()) {
      IntegrationHandler.syncStatusAutomationProcess(
        existingAccounts,
        validatedAccounts
      );
    }
  }
}
