public with sharing class CaseTeamMemberQueueable extends AbstractQueueable {
  private final List<SObject> cases;

  public CaseTeamMemberQueueable(List<SObject> cases) {
    super('CaseTeamMemberQueueable');
    this.cases = cases;
  }

  public override void work() {
    System.debug('CaseTeamMemberQueueable work');
    this.addDefaultCaseTeamMembers(cases);
  }

  public void addDefaultCaseTeamMembers(List<Case> cases) {
    List<CaseTeamMember> newCaseTeamMembers = new List<CaseTeamMember>();
    Map<Schema.SObjectField, String> fieldToRoleMap = new Map<Schema.SObjectField, String>();
    fieldToRoleMap.put(Case.Account_CSM__c, CaseMetadata.CSM_ROLE);
    fieldToRoleMap.put(Case.Account_STA__c, CaseMetadata.CTM_ROLE);

    for (Case caseRecord : cases) {
      for (Schema.SObjectField caseField : fieldToRoleMap.keySet()) {
        if (caseRecord.get(caseField) != null) {
          System.debug('Not blank ' + caseField);
          newCaseTeamMembers.add(
            getCaseTeamMember(caseRecord, (Id) caseRecord.get(caseField), fieldToRoleMap.get(caseField))
          );
        }
      }
    }
    if (!newCaseTeamMembers.isEmpty()) {
      Database.insert(newCaseTeamMembers, false);
    }
  }

  public static CaseTeamMember getCaseTeamMember(Case caseRecord, Id teamMemberId, String teamRole) {
    CaseTeamMember teamMember = new CaseTeamMember();
    teamMember.ParentId = caseRecord.Id;
    teamMember.MemberId = teamMemberId;
    teamMember.TeamRoleId = CaseMetaData.TeamRoleMap.get(teamRole);
    return teamMember;
  }

  public static void addDefaultTeamMembers(List<SObject> cases) {
    List<Case> eligibleCases = (List<Case>) Collection.of(cases)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.EngagementRequestRecordType,
              CaseMetadata.JapanEngagementRequestRecordType
            }
          )
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      AbstractQueueable.enqueue(new CaseTeamMemberQueueable(eligibleCases));
    }
  }

  public static void addDefaultTeamMembers(List<SObject> cases, Map<Id, SObject> existingCases) {
    SObjectPredicate hasChanged = new HasRecordChanged(
      new Set<SObjectField>{ Case.Account_CSM__c, Case.Account_STA__c },
      cases,
      existingCases
    );

    List<Case> eligibleCases = Collection.of(cases)
      .filter(hasChanged)
      .filter(
        Match.field(Case.RecordTypeId)
          .isIn(
            new Set<String>{
              CaseMetadata.IncidentRecordType,
              CaseMetadata.JapanIncidentRecordType,
              CaseMetadata.EngagementRequestRecordType,
              CaseMetadata.JapanEngagementRequestRecordType
            }
          )
      )
      .asList();

    if (!eligibleCases.isEmpty()) {
      AbstractQueueable.enqueue(new CaseTeamMemberQueueable(eligibleCases));
    }
  }
}
