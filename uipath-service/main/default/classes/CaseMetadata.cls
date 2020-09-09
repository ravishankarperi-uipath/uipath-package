public without sharing class CaseMetadata {
  public static final String CSM_ROLE = 'CSM';
  public static final String CTM_ROLE = 'Case Team Member';

  public static Id getRecordTypeId(String developerName) {
    Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    return recordTypeId;
  }

  public static Id EngagementRequestRecordType {
    get {
      return getRecordTypeId('Engagement_Request');
    }
    set;
  }

  public static Id JapanEngagementRequestRecordType {
    get {
      return getRecordTypeId('Japan_Engagement_Request');
    }
    set;
  }

  public static Id AcademyRecordType {
    get {
      return getRecordTypeId('Academy');
    }
    set;
  }

  public static Id ProactiveCareRecordType {
    get {
      return getRecordTypeId('Proactive_Care');
    }
    set;
  }
  public static Id IncidentRecordType {
    get {
      return getRecordTypeId('Incident');
    }
    set;
  }

  public static Id JapanAcademyRecordType {
    get {
      return getRecordTypeId('Japan_Academy');
    }
    set;
  }

  public static Id JapanIncidentRecordType {
    get {
      return getRecordTypeId('Japan_Incident');
    }
    set;
  }

  public static Id JapanLicensingRecordType {
    get {
      return getRecordTypeId('Japan_Licensing');
    }
    set;
  }

  public static Id SalesOperationRecordType {
    get {
      return getRecordTypeId('Sales_Operation');
    }
    set;
  }

  public static Id ServiceRequestRecordType {
    get {
      return getRecordTypeId('Service_Request');
    }
    set;
  }

  public static Id ServiceIncidentRecordType {
    get {
      return getRecordTypeId('Service_Incident');
    }
    set;
  }

  public static CPQ_Controls__mdt CPQControls {
    get {
      if (CPQControls == null) {
        CPQControls = [
          SELECT Id, Opp_CPQ_Record_Type_Developer_Name__c, Case_C_CaseTriggerHandler__c
          FROM CPQ_Controls__mdt
          LIMIT 1
        ];
      }
      return CPQControls;
    }
    set;
  }

  public static Map<String, Id> TeamRoleMap {
    get {
      if (TeamRoleMap == null) {
        TeamRoleMap = new Map<String, Id>();
        for (CaseTeamRole teamRole : [SELECT Id, Name FROM CaseTeamRole WHERE Name IN (:CSM_ROLE, :CTM_ROLE)]) {
          TeamRoleMap.put(teamRole.Name, teamRole.Id);
        }
      }
      return TeamRoleMap;
    }
    set;
  }

  public static Map<Schema.SObjectField, String> FieldToRoleMap {
    get {
      if (FieldToRoleMap == null) {
        FieldToRoleMap = new Map<Schema.SObjectField, String>();
        FieldToRoleMap.put(Case.Account_CSM__c, CSM_ROLE);
        FieldToRoleMap.put(Case.Account_STA__c, CTM_ROLE);
      }
      return FieldToRoleMap;
    }
    set;
  }
}
