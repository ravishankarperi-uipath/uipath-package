/**
*
* Author:       Daniel Sarchiz
* Date:         06/11/2017
* Description:  Class used to store global values
* Modification Log:
*           Name: Komal Karnawat, Slalom Consulting         Date: 23/04/2019        Des: Added the integration related Account and Address Constants
**/

public class Constants {

    /********** Account Constants ***********/
    // Account Record Type Field
    public static final String ACCOUNT_RECORD_TYPE_1 = 'Customer';
    public static final String ACCOUNT_RECORD_TYPE_2 = 'Partner';

    // Account Region Field
    public static final String ACCOUNT_REGION_1 = 'APAC';
    public static final String ACCOUNT_REGION_2 = 'Japan';
    public static final String ACCOUNT_REGION_3 = 'India';
    public static final String ACCOUNT_REGION_4 = 'Australia';
    public static final String ACCOUNT_REGION_5 = 'EMEA';
    public static final String ACCOUNT_REGION_6 = 'NAMER';
    public static final String ACCOUNT_REGION_7 = 'SAMER';

    //Account Validation Status
    public static final String ACC_VALIDATION_STATUS_VALIDATED = 'Validated';
    public static final String ACC_VALIDATION_STATUS_PENDING = 'Pending';
    public static final String ACC_VALIDATION_STATUS_READY_FOR_REVIEW = 'Ready For Review';

    //Account Sync Status
    public static final String ACC_SYNC_STATUS_VALID = 'Valid';
    public static final String ACC_SYNC_STATUS_NOT_VALID = 'Not Valid';
    public static final String ACC_SYNC_STATUS_PENDING = 'Pending';
    public static final String ACC_SYNC_STATUS_SYNCED = 'Synced';
    public static final String ACC_SYNC_STATUS_ERROR = 'Error';
    public static final String ACC_SYNC_STATUS_DO_NOT_SYNC = 'Do Not Sync';


    /********** Address Constants ***********/
    // Address Record Types
    public static final String ADDRESS_RECORD_TYPE_LOCKDOWN = 'Lockdown';


    //Address Validation Status
    public static final String ADD_VALIDATION_STATUS_VALIDATED = 'Validated';
    public static final String ADD_VALIDATION_STATUS_PENDING = 'Pending';
    public static final String ADD_VALIDATION_STATUS_READ_YFOR_REVIEW = 'Ready For Review';

    //Address Sync Status
    public static final String ADD_SYNC_STATUS_VALID = 'Valid';
    public static final String ADD_SYNC_STATUS_NOT_VALID = 'Not Valid';
    public static final String ADD_SYNC_STATUS_PENDING = 'Pending';
    public static final String ADD_SYNC_STATUS_SYNCED = 'Synced';
    public static final String ADD_SYNC_STATUS_ERROR = 'Error';
    public static final String ADD_SYNC_STATUS_DO_NOT_SYNC = 'Do Not Sync';

    /********** Opportunity Constants ***********/
    // Opportunity Stage Field
    public static final String OPPORTUNITY_STAGE_1 = 'Closed Won';
    public static final String OPPORTUNITY_STAGE_DISCOVERY = 'Discovery';

    // Opportunity Type Field
    public static final String OPPORTUNITY_TYPE_1 = 'Upsell';

    // Opportunity Led By Field
    public static final String OPPORTUNITY_LED_BY_1 = 'Direct Led';

    // Opportunity Vertical
    public static final String OPPORTUNITY_VERTICAL_1 = 'Manufacturing';

    // Opportunity Reasons
    public static final String OPPORTUNITY_REASON_1 = 'CoE enablement strategy';
    public static final String OPPORTUNITY_REASON_2 = 'Technical support';
    public static final String OPPORTUNITY_REASON_3 = 'Product roadmap';

    // Opportunity Type Field
    public static final String QUOTE_RENEWAL_TYPE = 'Renewal';
    public static final String QUOTE_QUOTE_TYPE = 'Quote';

    // Opportunity Deal Type Field
    public static final String OPPORTUNITY_DEALTYPE_DIRECT = 'Direct';

    /********** Case Constants ***********/
    // Case Record Types
    public static final String CASE_RECORD_TYPE_1 = 'Legal_Request';
    public static final String CASE_RECORD_TYPE_2 = 'Finance_Request';
    public static final String CASE_RECORD_TYPE_3 = 'Quick_Order';
    public static final String CASE_RECORD_TYPE_4 = 'Legal_Product_Request';

    // Case Status value
    public static final String CASE_STATUS_1  = 'Legal Review';
    public static final String CASE_STATUS_2  = 'Signed';
    public static final String CASE_STATUS_3  = 'Not Signed';
    public static final String CASE_STATUS_4  = 'Finance Review';
    public static final String CASE_STATUS_5  = 'Approved';
    public static final String CASE_STATUS_6  = 'In Progress';
    public static final String CASE_STATUS_7  = 'DocuSign Review';
    public static final String CASE_STATUS_8  = 'Out for Signature';
    public static final String CASE_STATUS_9  = 'Ready for Signature';
    
    // Case UiPath Signer Name
    public static final String CASE_UIPATH_SIGNER_FIRST_NAME_1 = 'Vasile';
    public static final String CASE_UIPATH_SIGNER_LAST_NAME_1 = 'Tiple';
    public static final String CASE_UIPATH_SIGNER_FIRST_NAME_2 = 'Mihai';
    public static final String CASE_UIPATH_SIGNER_LAST_NAME_2 = 'Faur';
    
    // Case UiPath Signer Title
    public static final String CASE_UIPATH_SIGNER_TITLE_1 = 'General Counsel';
    public static final String CASE_UIPATH_SIGNER_TITLE_2 = 'Chief Financial Officer';
    
    // Case Document Provider values
    public static final String CASE_DOCUMENT_PROVIDER_1  = 'UiPath';
    public static final String CASE_DOCUMENT_PROVIDER_2  = 'Customer / Partner';
    
    // Case Document Type values
    public static final String CASE_DOCUMENT_TYPE_1 = 'NDA';
    public static final String CASE_DOCUMENT_TYPE_2 = 'BPO General Terms';
    public static final String CASE_DOCUMENT_TYPE_3 = 'End Customer General Terms';
    public static final String CASE_DOCUMENT_TYPE_4 = 'Framework Agreement';
    public static final String CASE_DOCUMENT_TYPE_5 = 'License Order';
    public static final String CASE_DOCUMENT_TYPE_6 = 'Professional Services Order';
    public static final String CASE_DOCUMENT_TYPE_7 = 'Reseller Agreement';
    public static final String CASE_DOCUMENT_TYPE_8 = 'Sales Agent Agreement';
    public static final String CASE_DOCUMENT_TYPE_9 = 'Teaming Agreement';
    public static final String CASE_DOCUMENT_TYPE_10 = 'Training Partner Agreement';
    public static final String CASE_DOCUMENT_TYPE_11 = 'Other';
    
    // Case Files Upload
    public static final String CASE_FILE_ERROR_1 = 'There is a file attached already on this Case. Please open the existing Document from the Files section and select Upload New Version.';
    
    // Case Queues
    public static final String CASE_QUEUE_1  = 'Legal';
    public static final String CASE_QUEUE_2  = 'Finance';

    /********** Pre-sales Task Constants ***********/
    // Type
    public static final String PRESALES_TASK_TYPE_1  = 'Demo';

    // Demo Audience
    public static final String PRESALES_TASK_DEMO_AUDIENCE_1  = 'Technical';

    // Customer familiar with UiPath tools/prod
    public static final String PRESALES_TASK_CUSTOMER_FAMILIAR_WITH_TOOLS_1 = 'RPA Basics';

    /********** Other Constants ***********/
    // Quote
    public static final String QUOTE_RECORD_TYPE_1 = 'CPQ Default';
    public static final String QUOTE_RECORD_TYPE_2 = 'CPQ Approved';
    
    public static final String QUOTE_STATUS_1 = 'Draft';
    public static final String QUOTE_STATUS_2 = 'In Review';
    public static final String QUOTE_STATUS_3 = 'Approved';
    public static final String QUOTE_STATUS_4 = 'Denied';
    public static final String QUOTE_STATUS_5 = 'Presented';
    public static final String QUOTE_STATUS_6 = 'Accepted';
    public static final String QUOTE_STATUS_7 = 'Rejected';
    public static final String QUOTE_STATUS_8 = 'Booked';
    
    // DocuSign
    public static final String DOCUSIGN_ENVELOPE_STATUS_1 = 'Completed';
    public static final String DOCUSIGN_ENVELOPE_STATUS_2 = 'Declined';
    public static final String DOCUSIGN_ENVELOPE_STATUS_3 = 'Voided';
    public static final String DOCUSIGN_ENVELOPE_STATUS_4 = 'Sent';
    public static final String DOCUSIGN_ENVELOPE_STATUS_5 = 'Delivered';
    
    // User Profiles
    public static final String USER_PROFILE_1 = 'Legal User';
    public static final String USER_PROFILE_2 = 'Executive';
    public static final String STANDARD_USER_PROFILE ='Standard User';
    public static final String DATA_STEWARD_PROFILE ='Data Stewards';
    public static final String SUPER_ADMIN_PROFILE = 'Super Admin';
    public static final String INTEGRATION_USER_PROFILE ='Integration User';
    public static final String SYS_ADMIN_PROFILE ='System Administrator';
    public static final String GEO_LEADS_PROFILE = 'Sales Ops Geo Leads';


    //Integration Constants
    public static final String INTEGRATION_FIELDSET_NAME = 'Boomi_Integration_Field_Set';
    public static final String INTEGRATION_SYNC_STATUS_FIELD = 'Sync_Status__c';
    public static final String INTEGRATION_PROFILE_NAME = 'Integration User';
    public static final Set<String> INTEGRATION_OPPORTUNITY_STAGES = new Set<String>{'Negotiation', 'Closed Won Pending'};
    public static final Set<String> INTEGRATION_CASE_STATUSES = new Set<String>{'Finance Review'};

    public static final String BOOMI_INTEGRATION_PERMISSION_SET_NAME = 'DellBoomiIntegrationUser';


    //VAT Checker Constants
    public static final String VAT_CHECKER_VALID_MESSAGE = 'VAT Number is valid';
    public static final String VAT_CHECKER_INVALID_MESSAGE = 'VAT Number is Invalid';
    public static final String VAT_CHECKER_FAILED_MESSAGE = 'There\'s been a problem';
    public static final String VAT_CHECKER_VALID_STATUS = 'Valid';
    public static final String VAT_CHECKER_INVALID_STATUS = 'Invalid';
    public static final String VAT_CHECKER_FAILED_STATUS = 'Not Validated';
}