<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACTION_REQUIRED_Proposal_Only</fullName>
        <ccEmails>awesley@dt.com</ccEmails>
        <description>ACTION REQUIRED: Proposal Only</description>
        <protected>false</protected>
        <recipients>
            <recipient>gzappa@dt.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ACTION_REQUIRED_RFP_Proposal_Price_Quote</template>
    </alerts>
    <alerts>
        <fullName>Expired_Close_Date_on_Open_Opportunity</fullName>
        <ccEmails>mkrazit@dt.com</ccEmails>
        <description>Expired Close Date on Open Opportunity</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Expired_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Avenir_Won_Email_Alert</fullName>
        <ccEmails>salesforcesupport@dt.com</ccEmails>
        <description>Opportunity Avenir Won Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>jdilorenzo@dt.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mcallahan@dt.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Opportunity_Avenir_Closed_Won</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Upsell_Consulting_Hotel_Email_Alert</fullName>
        <ccEmails>salesforcesupport@dt.com, directview@dt.com</ccEmails>
        <description>Opportunity Upsell Consulting Hotel Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Opportunity_Hotel_Consulting_Intake</template>
    </alerts>
    <alerts>
        <fullName>Oppty_Stage_Verbal_Alert</fullName>
        <ccEmails>salesforcesupport@dt.com</ccEmails>
        <description>Oppty Stage Verbal Alert Ops</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Executive_Operations_Canada</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Operations_Leader_US_Core</recipient>
            <type>role</type>
        </recipients>
        <senderAddress>noreply@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Opportunity_VOC_Verbal_Stage_Ops</template>
    </alerts>
    <alerts>
        <fullName>Oppty_Stage_Verbal_Alert_AMs_not_CA</fullName>
        <ccEmails>salesforcesupport@dt.com</ccEmails>
        <description>Oppty Stage Verbal Alert AMs not CA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>AM_US_Leader_DS_MM</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>AM_US_Leader_Enterprise</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Customer_Success_US_Leader</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>jtornatore@dt.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kakerman@dt.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Opportunity_VOC_Verbal_Stage</template>
    </alerts>
    <alerts>
        <fullName>Oppty_Stage_Verbal_Implementation_Email_Alert</fullName>
        <ccEmails>salesforcesupport@dt.com</ccEmails>
        <description>Oppty Stage Verbal Implementation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>impsupport@dt.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Oppty_Stage_Verbal_Implementation_Email</template>
    </alerts>
    <alerts>
        <fullName>Test</fullName>
        <ccEmails>awesley@dt.com</ccEmails>
        <description>Test</description>
        <protected>false</protected>
        <recipients>
            <recipient>mkrazit@dt.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sincedayi@dt.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ACTION_REQUIRED_RFP_Pricing_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Default_Opportunity_Stage</fullName>
        <field>StageName</field>
        <literalValue>Prospecting</literalValue>
        <name>Default Opportunity Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Name</fullName>
        <field>Name</field>
        <formula>Account.Name + &quot; - New Business - &quot; + TEXT(YEAR( DATEVALUE(NOW())))</formula>
        <name>Opportunity Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opportunity_Source_Company_to_Concur</fullName>
        <field>Opportunity_Source_Company__c</field>
        <literalValue>Concur</literalValue>
        <name>Set Opportunity Source Company to Concur</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Expired Close Date</fullName>
        <actions>
            <name>Expired_Close_Date_on_Open_Opportunity</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Closed - Won,Closed - Lost,Closed - Invalid</value>
        </criteriaItems>
        <description>alert when the Close Date has expired on an Open Opportunity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Opportunity Closed</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Email alert to Ronda Shipley when new business is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Naming Convention</fullName>
        <actions>
            <name>Opportunity_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Sales - Meetings,Existing Clients,New Business - Global,Spotnana</value>
        </criteriaItems>
        <description>Enforce Opportunity Name field&apos;s naming convention</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Opportunity Source Company</fullName>
        <actions>
            <name>Set_Opportunity_Source_Company_to_Concur</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Opportunity_Source__c</field>
            <operation>equals</operation>
            <value>Concur Referral</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
