@isTest
public class CaseTechPartnerAgreementQueueableTest {
  @isTest
  private static void whenSigned_updateTechnologyPartnershipSignedDate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id legalProductRequestRecordTypeId = SalesCaseMetadata.LegalProductRequestRecordType;

    Account accountRecord = new Account(
      Name = 'New Account',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      Validation_Status__c = 'Validated',
      Sync_Status__c = 'Synced'
    );
    insert accountRecord;

    Case oldCase = new Case(
      Subject = 'Test',
      AccountId = accountRecord.Id,
      RecordTypeId = legalProductRequestRecordTypeId,
      Status = 'New'
    );

    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      AccountId = accountRecord.Id,
      RecordTypeId = legalProductRequestRecordTypeId,
      Status = SalesCaseMetadata.SIGNED,
      Document_Type__c = SalesCaseMetadata.TECHNOLOGY_ALLIANCE_AGREEMENT
    );
    new CaseTechPartnerAgreementQueueable(new List<Case>{ updatedCase }).work();
    accountRecord = [
      SELECT
        Id,
        Allbound_Status__c,
        Technology_Partner_Level__c,
        Technology_Partnership_signed_Date__c,
        Technology_Partnership_Deny_Date__c
      FROM Account
      WHERE Id = :accountRecord.Id
    ];
    System.assertEquals('Active', accountRecord.Allbound_Status__c, 'All Bound Status is not Active');
    System.assertEquals(
      'Registered',
      accountRecord.Technology_Partner_Level__c,
      'Technology Partner level is not Registered'
    );
    System.assertNotEquals(
      null,
      accountRecord.Technology_Partnership_signed_Date__c,
      'Technology Partnership signed date is null'
    );
    System.assertEquals(
      null,
      accountRecord.Technology_Partnership_Deny_Date__c,
      'Technology Partnership Deny date is not null'
    );
  }

  @isTest
  private static void whenNotSigned_updateTechnologyPartnershipDenyDate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id legalProductRequestRecordTypeId = SalesCaseMetadata.LegalProductRequestRecordType;

    Account accountRecord = new Account(
      Name = 'New Account',
      BillingCountry = 'United Kingdom',
      Industry = 'Others',
      Validation_Status__c = 'Validated',
      Sync_Status__c = 'Synced'
    );
    insert accountRecord;

    Case oldCase = new Case(
      Subject = 'Test',
      AccountId = accountRecord.Id,
      RecordTypeId = legalProductRequestRecordTypeId,
      Status = 'New'
    );

    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      AccountId = accountRecord.Id,
      RecordTypeId = legalProductRequestRecordTypeId,
      Status = SalesCaseMetadata.NOT_SIGNED,
      Document_Type__c = SalesCaseMetadata.TECHNOLOGY_ALLIANCE_AGREEMENT
    );
    new CaseTechPartnerAgreementQueueable(new List<Case>{ updatedCase }).work();
    accountRecord = [
      SELECT
        Id,
        Allbound_Status__c,
        Technology_Partner_Level__c,
        Technology_Partnership_signed_Date__c,
        Technology_Partnership_Deny_Date__c
      FROM Account
      WHERE Id = :accountRecord.Id
    ];
    System.assertEquals(null, accountRecord.Allbound_Status__c, 'All Bound Status is not null');
    System.assertEquals(null, accountRecord.Technology_Partner_Level__c, 'Technology Partner level is not null');
    System.assertEquals(
      null,
      accountRecord.Technology_Partnership_signed_Date__c,
      'Technology Partnership signed date is null'
    );
    System.assertNotEquals(
      null,
      accountRecord.Technology_Partnership_Deny_Date__c,
      'Technology Partnership Deny date is null'
    );
  }
}
