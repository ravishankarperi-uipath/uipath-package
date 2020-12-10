/**
 * @author UiPath SalesTech Team
 * @date 07/12/2020
 *
 * Publishes events to the UiPath Connector/Orchestrator framework.
 * This process involves DML for inserting into an Event table owned by the UiPath connector package.
 * As DML is involved, we break the transaction - and so the QueueNotificationService in invoked from a Queueable Context
 *
 */
public class OrchestratorNotifierQueueable extends AbstractQueueable {
  //Records in the current transaction
  private final List<SObject> records;

  //Records as saved previously in DB
  private final Map<Id, SObject> oldRecords;

  //Connector template configured in the Package config
  private final String templateName;

  //Set of Fields the interface is sensitive to. Checked for Change in current transaction.
  private Set<SObjectField> fieldsToCheckForChange;

  //Predicate with any combination of filters for specifying which records are eligible
  private SObjectPredicate filterConditions;

  //set after the change-check and filters applied. These are the final list of records that will be published.
  private List<SObject> eligibleRecords;

  //set this to publish in the same transaction and not enqueue a Queueable.
  //Can be very handy in Tests fore example
  private Boolean syncMode = false;

  //Number of records send to the connector. Note that this does not mean Successful publishing
  //This just signifies the number of records sent to the Service.
  public Integer numberOfRecordsPublished = 0;

  //To be used in contexts where the notifier instance is not acccessible but you still want to force a sync publish
  public static Boolean forceSyncMode = false;

  //Custom name value pairs
  private final Map<String, String> customParams;

  /**
   * Constructor is private.
   * Can only be constructed with the builder to ensure correct setup
   *
   */
  private OrchestratorNotifierQueueable(Builder builder) {
    super('OrchestratorNotificationQueueable');
    this.records = builder.records;
    this.oldRecords = builder.oldRecords;
    this.templateName = builder.templateName;
    this.fieldsToCheckForChange = builder.fieldsToCheckForChange;
    this.filterConditions = builder.filterConditions;
    this.syncMode = builder.syncMode;
    this.customParams = builder.customParams;
  }

  /**
   * Called when the Queueable actually runs
   */
  public override void work() {
    notifyOrchestrator();
  }

  /**
   *  Calls the QueueNotificationService with the
   */
  public void notifyOrchestrator() {
    List<UiPath.QueueNotificationRequest> queueRequestsLst = new List<UiPath.QueueNotificationRequest>();

    for (Id recordId : (new Map<Id, SObject>(eligibleRecords)).keySet()) {
      UiPath.QueueNotificationRequest recordQueueReq = new UiPath.QueueNotificationRequest();
      recordQueueReq.templateName = this.templateName;
      recordQueueReq.recordId = recordId;
      recordQueueReq.validCustomValues = this.customParams;
      queueRequestsLst.add(recordQueueReq);
    }

    //call the SF Connector integration service
    Uipath.QueueNotificationService.createNotifications(queueRequestsLst);

    this.numberOfRecordsPublished = numberOfRecordsPublished + eligibleRecords.size();
  }

  public void publishNewRecords() {
    //Clear out in case of any recursion
    eligibleRecords = new List<SObject>();

    //Filter out records that we aren't interested in
    for (SObject record : records) {
      if (filterConditions == null) {
        eligibleRecords.add(record);
      } else if (filterConditions.apply(record)) {
        eligibleRecords.add(record);
      }
    }

    if (!eligibleRecords.isEmpty()) {
      this.customParams.put('action', 'add');
      //Enqueue job if sync mode is not enabled
      if (syncMode == false) {
        AbstractQueueable.enqueue(this);
      }

      //Publish immediately if sync mode is enabled
      if ((syncMode == true || forceSyncMode == true)) {
        notifyOrchestrator();
      }
    }
  }

  /**
   * Typically called from an After Update trigger context.
   * Checks is relevant fields have changed, applies further filters as supplied, then finally enqueues the notifier
   */
  public void publishUpdatedRecords() {
    if (oldRecords == null) {
      throw new IllegalStateException('oldRecords is not set, so cannot process updates');
    }

    if (fieldsToCheckForChange == null) {
      throw new IllegalStateException('At least one field must be provided in the fieldsToCheckForChange parameter');
    }

    SObjectPredicate hasChanged = new HasRecordChanged(fieldsToCheckForChange, records, oldRecords);

    //Clear out in case of any recursion
    eligibleRecords = new List<SObject>();

    //Filter out records that we aren't interested in
    for (SObject record : records) {
      if (filterConditions.apply(record) && hasChanged.apply(record)) {
        eligibleRecords.add(record);
      }
    }

    if (!eligibleRecords.isEmpty()) {
      //set Action. This can be used by the Robot to branch logic on new/update/delete
      this.customParams.put('action', 'update');
      //Enqueue job if sync mode is not enabled
      if (syncMode == false) {
        AbstractQueueable.enqueue(this);
      }
      //Publish immediately if sync mode is enabled
      if ((syncMode == true || forceSyncMode == true)) {
        notifyOrchestrator();
      }
    }
  }

  public Map<String, String> getParams() {
    return this.customParams;
  }

  /**
   * Builder to support a fluent style of coding
   */
  public class Builder {
    private List<SObject> records;
    private Map<Id, SObject> oldRecords;
    private String templateName;
    private Set<SObjectField> fieldsToCheckForChange;
    private SObjectPredicate filterConditions;
    private Boolean syncMode = false;
    private Map<String, String> customParams = new Map<String, String>();

    /**
     * No Args constructor is disallowed so make private
     */
    private Builder() {
    }

    /**
     * Constructor
     * @param records records in the current transaction context
     * @param templateName The Actual Event type(and inherently the target integration context) is identified by a unique Template Name which is configured as part of the Connector setup
     */
    public Builder(List<SObject> records, String templateName) {
      if (records == null || templateName == null) {
        throw new IllegalArgumentException('records list and templateName are both required');
      }
      this.records = records;
      this.templateName = templateName;
    }

    /**
     * @param fieldsToCheckForChange Set of fields that will be checked for changes.
     * The notification will proceed only if at least one of the supplied fields was changed in the current transaction.
     *
     * @return builder instance
     */
    public Builder withFieldsToCheckForChange(Set<SObjectField> fieldsToCheckForChange) {
      this.fieldsToCheckForChange = fieldsToCheckForChange;
      return this;
    }

    /**
     * @param filterConditions Predicate that specifies which records are eligible for this interface
     *
     * @return builder instance
     */
    public Builder withFilterConditions(SObjectPredicate filterConditions) {
      this.filterConditions = filterConditions;
      return this;
    }

    /**
     * @param syncMode setting this causes publishing immediately and avoid Queueing
     *
     * @return builder instance
     */
    public Builder setSyncMode(Boolean syncMode) {
      this.syncMode = syncMode;
      return this;
    }

    /**
     * @param oldRecords to be provided for when the notification is involved in an Update context
     *
     * @return wip builder instance
     */
    public Builder withOldRecords(Map<Id, SObject> oldRecords) {
      this.oldRecords = oldRecords;
      return this;
    }

    /**
     * @param customParams name value pairs sent to orchestrator
     *
     * @return wip builder instance
     */
    public Builder withCustomParams(Map<String, String> customParams) {
      if (customParams != null) {
        this.customParams = customParams;
      }
      return this;
    }

    /**
     * @param paramName Name of Custom param
     * @param value  Value
     *
     * @return
     */
    public Builder withParam(String paramName, String value) {
      if (paramName != null) {
        this.customParams.put(paramName, value);
      }
      return this;
    }

    public OrchestratorNotifierQueueable endSetup() {
      //Add a fake condition if none is set
      if (filterConditions == null) {
        filterConditions = Match.field('Id').hasValue();
      }
      return new OrchestratorNotifierQueueable(this);
    }
  }

  public static Builder beginSetup(List<SObject> records, String templateName) {
    return new Builder(records, templateName);
  }
}
