@IsTest
public class SalesCaseDocumentTypeFunctionTest {
  @IsTest
  private static void whenDocumentTypeAloneIsPresent_setTemplateId() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id accessId = fflib_IDGenerator.generate(AI_Early_Access_Program__c.SObjectType);

    Id reccordTypeId = SalesCaseMetadata.FinanceRequestRecordType;
    for (Template_Mapping__mdt templateMapping : [
      SELECT Id, IsActive__c, CongaTemplateId__c, DocumentType__c
      FROM Template_Mapping__mdt
      WHERE IsActive__c = true AND DocumentLanguage__c = null
      LIMIT 10
    ]) {
      Case newCase = new Case(
        Id = caseId,
        Subject = 'Test',
        RecordTypeId = reccordTypeId,
        Status = 'New',
        Document_Type__c = templateMapping.DocumentType__c,
        Conga_Template_2__c = ''
      );

      if (newCase.Document_Type__c.startsWith('EAAP Agreement')) {
        newCase.AI_Early_Access_Program__c = accessId;
      }
      if (newCase.Document_Type__c == 'Undertaking by Original Software Developer (for Software) pre Signed') {
        newCase.Standard_Template__c = SalesCaseMetadata.NON_EDITABLE_STANDARD;
      }
      if (newCase.Document_Type__c == 'USN Addendum') {
        continue;
      }
      fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ newCase });
      fflib_SObjectDomain.triggerHandler(SalesCases.class);
      System.assertEquals(
        newCase.Conga_Template_2__c,
        SalesCaseMetadata.DocumentTypeMapping.get(newCase.Document_Type__c)
      );
    }
  }

  @IsTest
  private static void whenDocumentTypeAndLanguageArePresent_setTemplateId() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id reccordTypeId = SalesCaseMetadata.FinanceRequestRecordType;

    for (Template_Mapping__mdt templateMapping : [
      SELECT Id, IsActive__c, CongaTemplateId__c, DocumentType__c, DocumentLanguage__c
      FROM Template_Mapping__mdt
      WHERE IsActive__c = true AND DocumentLanguage__c != null
    ]) {
      Case newCase = new Case(
        Id = caseId,
        Subject = 'Test',
        RecordTypeId = reccordTypeId,
        Status = 'New',
        Document_Type__c = templateMapping.DocumentType__c,
        Document_Language__c = templateMapping.DocumentLanguage__c,
        Conga_Template_2__c = ''
      );

      if (newCase.Document_Type__c.startsWith('MPA Indirect Resale') || newCase.Document_Type__c != 'DPA') {
        continue;
      }
      fflib_SObjectDomain.Test.Database.onInsert(new List<Case>{ newCase });
      fflib_SObjectDomain.triggerHandler(SalesCases.class);
      System.assertEquals(
        newCase.Conga_Template_2__c,
        SalesCaseMetadata.DocumentTypeMapping.get(newCase.Document_Type__c)
      );
    }
  }

  @IsTest
  private static void whenDocumentTypeAndLanguageArePresent_setTemplateIdOnUpdate() {
    Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
    Id reccordTypeId = SalesCaseMetadata.FinanceRequestRecordType;

    for (Template_Mapping__mdt templateMapping : [
      SELECT Id, IsActive__c, CongaTemplateId__c, DocumentType__c, DocumentLanguage__c
      FROM Template_Mapping__mdt
      WHERE IsActive__c = true AND DocumentLanguage__c != null
    ]) {
      Case oldCase = new Case(Id = caseId, Subject = 'Test', RecordTypeId = reccordTypeId, Status = 'New');
      Case updatedCase = new Case(
        Id = caseId,
        Subject = 'Test',
        RecordTypeId = reccordTypeId,
        Status = 'New',
        Document_Type__c = templateMapping.DocumentType__c,
        Document_Language__c = templateMapping.DocumentLanguage__c,
        Conga_Template_2__c = ''
      );

      if (updatedCase.Document_Type__c.startsWith('MPA Indirect Resale') || updatedCase.Document_Type__c != 'DPA') {
        continue;
      }

      fflib_SObjectDomain.Test.Database.onUpdate(
        new List<Case>{ updatedCase },
        new Map<Id, SObject>{ oldCase.Id => oldCase }
      );
      fflib_SObjectDomain.triggerHandler(SalesCases.class);
      System.assertEquals(
        updatedCase.Conga_Template_2__c,
        SalesCaseMetadata.DocumentTypeMapping.get(updatedCase.Document_Type__c)
      );
    }
  }
}
