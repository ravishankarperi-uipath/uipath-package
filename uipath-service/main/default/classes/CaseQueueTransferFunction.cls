public with sharing class CaseQueueTransferFunction implements SObjectToSObjectFunction {
  public static Map<String, String> queueToRelatedToMap;
  public static Map<String, Id> queueToRecordTypeIdMap;

  public CaseQueueTransferFunction() {
    queueToRelatedToMap = new Map<String, String>();
    queueToRelatedToMap.put('Studio_Queue', 'Studio');
    queueToRelatedToMap.put('Product_Support_Queue', 'Studio');
    queueToRelatedToMap.put('Partner_Product', 'Partner Product');
    queueToRelatedToMap.put('Robot_Queue', 'Robot');
    queueToRelatedToMap.put('Orchestrator_Queue', 'Orchestrator');
    queueToRelatedToMap.put('Japan_Academy_Queue', 'Academy');
    queueToRelatedToMap.put('Academy', 'Academy');
    queueToRelatedToMap.put('Japan_Licensing_Queue', 'Cloud Platform');
    queueToRelatedToMap.put('Sales_Operations_Queue', 'Other');
    //queueToRelatedToMap.put('ER_Queue', '');
    //queueToRelatedToMap.put('Japan_ER_Queue', '');
    queueToRelatedToMap.put('Japan_Studio_Queue', 'Studio');
    queueToRelatedToMap.put('Japan_Partner_Product', 'Partner Product');
    queueToRelatedToMap.put('Japan_Robot_Queue', 'Robot');
    queueToRelatedToMap.put('Japan_Orchestrator_Queue', 'Orchestrator');
    queueToRelatedToMap.put('Japan_Product_Support_Queue', 'Studio');

    queueToRecordTypeIdMap = new Map<String, Id>();
    queueToRecordTypeIdMap.put('Studio_Queue', CaseMetadata.IncidentRecordType);
    queueToRecordTypeIdMap.put('Product_Support_Queue', CaseMetadata.IncidentRecordType);
    queueToRecordTypeIdMap.put('Partner_Product', CaseMetadata.IncidentRecordType);
    queueToRecordTypeIdMap.put('Robot_Queue', CaseMetadata.IncidentRecordType);
    queueToRecordTypeIdMap.put('Orchestrator_Queue', CaseMetadata.IncidentRecordType);
    queueToRecordTypeIdMap.put('Japan_Academy_Queue', CaseMetadata.JapanAcademyRecordType);
    queueToRecordTypeIdMap.put('Academy', CaseMetadata.AcademyRecordType);
    queueToRecordTypeIdMap.put('Japan_Licensing_Queue', CaseMetadata.JapanLicensingRecordType);
    queueToRecordTypeIdMap.put('Sales_Operations_Queue', CaseMetadata.SalesOperationRecordType);
    queueToRecordTypeIdMap.put('ER_Queue', CaseMetadata.EngagementRequestRecordType);
    queueToRecordTypeIdMap.put('Japan_ER_Queue', CaseMetadata.JapanEngagementRequestRecordType);
    queueToRecordTypeIdMap.put('Japan_Studio_Queue', CaseMetadata.JapanIncidentRecordType);
    queueToRecordTypeIdMap.put('Japan_Partner_Product', CaseMetadata.JapanIncidentRecordType);
    queueToRecordTypeIdMap.put('Japan_Robot_Queue', CaseMetadata.JapanIncidentRecordType);
    queueToRecordTypeIdMap.put('Japan_Orchestrator_Queue', CaseMetadata.JapanIncidentRecordType);
    queueToRecordTypeIdMap.put('Japan_Product_Support_Queue', CaseMetadata.JapanIncidentRecordType);
  }

  public SObject apply(Case caseRecord) {
    return caseRecord;
  }

  public SObject apply(SObject record) {
    return apply((Case) record);
  }

  private void changeRecordtypeOnQueueTransfer(List<Case> casesToUpdate) {
    Map<Id, Group> queueMap = new Map<Id, Group>(
      [SELECT Id, DeveloperName, Type FROM Group WHERE DeveloperName IN :QUEUE_NAMES]
    );
    for (Case caseRecord : casesToUpdate) {
      if (!queueMap.containsKey(caseRecord.OwnerId)) {
        continue;
      }
      String ownerQueueName = queueMap.get(caseRecord.OwnerId).DeveloperName;
      caseRecord.RecordTypeId = queueToRecordTypeIdMap.get(ownerQueueName);

      if (caseRecord.Related_To__c == null) {
        caseRecord.Related_To__c = queueToRelatedToMap.get(ownerQueueName);
      }

      if (INCIDENT_QUEUE_NAMES.contains(ownerQueueName) || JAPAN_QUEUE_NAMES.contains(ownerQueueName)) {
        if (caseRecord.Related_To__c == 'Academy' || caseRecord.Related_To__c == 'Cloud Platform') {
          caseRecord.Related_To__c = queueToRelatedToMap.get(ownerQueueName);
        }
      }
    }
  }

  public static void deriveRelatedTo(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(new Set<SObjectField>{ Case.OwnerId }, cases, existingCases);
    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.AcademyRecordType,
              CaseMetadata.IncidentRecordType,
              CaseMetadata.JapanAcademyRecordType,
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.JapanLicensingRecordType,
              CaseMetadata.SalesOperationRecordType,
              CaseMetadata.ServiceRequestRecordType,
              CaseMetadata.ServiceIncidentRecordType,
              CaseMetadata.EngagementRequestRecordType,
              CaseMetadata.JapanEngagementRequestRecordType
            }
          )
      )
      .asList();
    if (!eligibleCases.isEmpty()) {
      new CaseQueueTransferFunction().changeRecordtypeOnQueueTransfer(eligibleCases);
    }
  }

  final static Set<String> INCIDENT_QUEUE_NAMES = new Set<String>{
    'Product_Support_Queue',
    'Partner_Product',
    'Robot_Queue',
    'Studio_Queue',
    'Orchestrator_Queue'
  };
  final static Set<String> JAPAN_QUEUE_NAMES = new Set<String>{
    'Japan_Product_Support_Queue',
    'Japan_Orchestrator_Queue',
    'Japan_Robot_Queue',
    'Japan_Partner_Product',
    'Japan_Studio_Queue'
  };

  final static Set<String> QUEUE_NAMES = new Set<String>{
    'Academy',
    'ER_Queue',
    'Japan_ER_Queue',
    'Japan_Academy_Queue',
    'Japan_Orchestrator_Queue',
    'Japan_Robot_Queue',
    'Japan_Licensing_Queue',
    'Japan_Partner_Product',
    'Japan_Product_Support_Queue',
    'Japan_Studio_Queue',
    'Orchestrator_Queue',
    'Partner_Product',
    'Product_Support_Queue',
    'Robot_Queue',
    'Sales_Operations_Queue',
    'Studio_Queue'
  };
}
