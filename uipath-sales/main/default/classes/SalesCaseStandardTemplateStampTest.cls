@IsTest
public class SalesCaseStandardTemplateStampTest {
  @IsTest
  private static void testStandardTemplateStampOnInsert() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id legalRequestRecordTypeId = SalesCaseMetadata.LegalRequestRecordType;

    Account acc = new Account(
      Id = accountId,
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      Industry = 'Others'
    );

    Case cs = new Case(
      AccountId = accountId,
      Id = caseId,
      Subject = 'Case1',
      RecordTypeId = legalRequestRecordTypeId,
      Status = 'New',
      Standard_Template__c = 'No'
    );

    fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ cs });

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals('No', cs.Standard_Template_Stamp__c);
  }

  @IsTest
  private static void testStandardTemplateStampOnUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id legalRequestRecordTypeId = SalesCaseMetadata.LegalRequestRecordType;

    Account acc = new Account(
      Id = accountId,
      Name = 'TestAccountUK',
      Country__c = 'United Kingdom',
      BillingCountry = 'United Kingdom',
      Industry = 'Others'
    );

    Case oldCase = new Case(
      AccountId = accountId,
      Id = caseId,
      Subject = 'Case1',
      RecordTypeId = legalRequestRecordTypeId,
      Status = 'New'
    );

    Case updatedCase = new Case(
      AccountId = accountId,
      Id = caseId,
      Subject = 'Case1',
      RecordTypeId = legalRequestRecordTypeId,
      Status = 'New',
      Standard_Template__c = 'No'
    );

    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(SalesCases.class);

    System.assertEquals('No', updatedCase.Standard_Template_Stamp__c);
  }
}
