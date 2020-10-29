@IsTest
public class SalesCaseOwnerAssignmentFunctionTest {
  @TestSetup
  static void makeData() {
    Account account = new Account(Name = 'John');
    account.BillingStreet = 'Test Street';
    account.BillingCity = 'Test City';
    account.BillingPostalCode = 'SW1 3DWW';
    account.BillingCountry = 'United Kingdom';
    account.Phone = '1234567890';
    account.Industry = 'Others';
    insert account;
  }

  @IsTest
  private static void whenStatusIsPendingSales_OwnerIsSales() {
    Account acc = [SELECT Id, OwnerId FROM Account LIMIT 1];
    Id legalRecordType = SalesCaseMetadata.LegalRequestRecordType;
    Case oldCase = new Case(Subject = 'Test', RecordTypeId = legalRecordType, AccountId = acc.Id, Status = 'New');
    insert oldCase;
    Case updatedCase = new Case(
      Id = oldCase.Id,
      Subject = 'Test',
      RecordTypeId = legalRecordType,
      AccountId = acc.Id,
      Status = SalesCaseMetadata.PENDING_SALES_INFORMATION
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals(acc.OwnerId, updatedCase.OwnerId, 'Case Owner is not updated');
  }

  @IsTest
  private static void whenStatusIsInProgress_OwnerIsLegal() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id userId = fflib_IDGenerator.generate(User.SObjectType);
    Id legalRecordType = SalesCaseMetadata.LegalRequestRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = legalRecordType, Status = 'New');
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = legalRecordType,
      Status = SalesCaseMetadata.IN_PROGRESS,
      Legal_Owner__c = userId
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals(userId, updatedCase.OwnerId, 'Case Owner is not updated');
  }

  @IsTest
  private static void whenStatusIsDealHubReview_OwnerIsDevHub() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id userId = fflib_IDGenerator.generate(User.SObjectType);
    Id legalRecordType = SalesCaseMetadata.LegalRequestRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = legalRecordType, Status = 'New');
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = legalRecordType,
      Status = SalesCaseMetadata.DEAL_HUB_REVIEW,
      Deal_Hub_Owner__c = userId
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals(userId, updatedCase.OwnerId, 'Case Owner is not updated');
  }

  @IsTest
  private static void whenStatusIsFinanceReview_OwnerIsFinance() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id userId = fflib_IDGenerator.generate(User.SObjectType);
    Id legalRecordType = SalesCaseMetadata.LegalRequestRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = legalRecordType, Status = 'New');
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = legalRecordType,
      Status = SalesCaseMetadata.FINANCE_REVIEW,
      Finance_Owner__c = userId
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals(userId, updatedCase.OwnerId, 'Case Owner is not updated');
  }

  @IsTest
  private static void whenStatusIsLegalReview_OwnerIsLegal() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id userId = fflib_IDGenerator.generate(User.SObjectType);
    Id legalRecordType = SalesCaseMetadata.LegalRequestRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = legalRecordType, Status = 'New');
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = legalRecordType,
      Status = SalesCaseMetadata.LEGAL_REVIEW,
      Legal_Owner__c = userId
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals(userId, updatedCase.OwnerId, 'Case Owner is not updated');
  }

  @IsTest
  private static void whenStatusIsReadyForSign_OwnerIsDealHub() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id userId = fflib_IDGenerator.generate(User.SObjectType);
    Id legalRecordType = SalesCaseMetadata.LegalRequestRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = legalRecordType, Status = 'New');
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = legalRecordType,
      Status = SalesCaseMetadata.READY_FOR_SIGNATURE,
      Deal_Hub_Owner__c = userId
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals(userId, updatedCase.OwnerId, 'Case Owner is not updated');
  }

  @IsTest
  private static void whenStatusIsMasterData_OwnerIsMasterData() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id userId = fflib_IDGenerator.generate(User.SObjectType);
    Id financeRecordType = SalesCaseMetadata.FinanceRequestRecordType;
    Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = financeRecordType, Status = 'New');
    Case updatedCase = new Case(
      Id = caseId,
      Subject = 'Test',
      RecordTypeId = financeRecordType,
      Status = SalesCaseMetadata.MASTER_DATA_REVIEW,
      Master_Data_Owner__c = userId
    );
    fflib_SObjectDomain.Test.Database.onUpdate(
      new List<Case>{ updatedCase },
      new Map<Id, SObject>{ oldCase.Id => oldCase }
    );

    fflib_SObjectDomain.triggerHandler(SalesCases.class);
    System.assertEquals(userId, updatedCase.OwnerId, 'Case Owner is not updated');
  }
}
