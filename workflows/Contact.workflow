<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CAN_Standard_Travel_Alert_Checked</fullName>
        <ccEmails>TravelAlerts@dt.com</ccEmails>
        <description>CAN_Standard_Travel_Alert_Checked</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CAN_STD_Travel_Alert_Checked</template>
    </alerts>
    <alerts>
        <fullName>CAN_Standard_Travel_Alert_Checked_and_Email_Changed</fullName>
        <ccEmails>TravelAlerts@dt.com</ccEmails>
        <description>CAN_Standard_Travel_Alert_Checked and Email Changed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Canada_Standard_Travel_Alert_Checked_and_Email_Changed</template>
    </alerts>
    <alerts>
        <fullName>CAN_Standard_Travel_Alert_Unchecked</fullName>
        <ccEmails>TravelAlerts@dt.com</ccEmails>
        <description>CAN_Standard_Travel_Alert_Unchecked</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CAN_STD_Travel_Alert_Unchecked</template>
    </alerts>
    <alerts>
        <fullName>Contact_Email_Opt_Out_Email_Alert</fullName>
        <ccEmails>salesforcesupport@dt.com</ccEmails>
        <description>Contact Email Opt Out Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Contact_Email_Opt_Out_Intake</template>
    </alerts>
    <alerts>
        <fullName>Crisis24_Admin_Addition</fullName>
        <ccEmails>productsupport@dt.com</ccEmails>
        <description>Crisis24 Admin - Addition</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Crisis24_Admin_Checked</template>
    </alerts>
    <alerts>
        <fullName>Crisis24_Admin_Checked_and_Email_Changed</fullName>
        <ccEmails>ProductSupport@dt.com</ccEmails>
        <description>Crisis24 Admin Checked and Email Changed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Crisis24_Admin_Checked_and_Email_Changed</template>
    </alerts>
    <alerts>
        <fullName>Crisis24_Admin_Removal</fullName>
        <ccEmails>productsupport@dt.com</ccEmails>
        <description>Crisis24 Admin - Removal</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Crisis24_Admin_Removal</template>
    </alerts>
    <alerts>
        <fullName>Travel_Survey_Opt_Out</fullName>
        <ccEmails>Direct2U@dt.com</ccEmails>
        <description>Travel Survey Opt-Out</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Traveler_Survey_Opt_Out_Checked</template>
    </alerts>
    <alerts>
        <fullName>Travel_Survey_Opt_Out_Un_checked_opt_in</fullName>
        <ccEmails>Direct2U@dt.com</ccEmails>
        <description>Travel Survey Opt-Out Un-checked (opt-in)</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Traveler_Survey_Opt_Out_Un_Checked_Opt_in</template>
    </alerts>
    <rules>
        <fullName>Crisis24 Admin Checked</fullName>
        <actions>
            <name>Crisis24_Admin_Addition</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Add Crisis24 Admin to GardaWorld</description>
        <formula>Crisis24_Admin__c = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crisis24 Admin Checked and Email Changed</fullName>
        <active>true</active>
        <formula>AND( Crisis24_Admin__c = TRUE, ISCHANGED( Email ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crisis24 Admin Removal</fullName>
        <actions>
            <name>Crisis24_Admin_Removal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email Product Support when Crisis24 is removed</description>
        <formula>AND( ISCHANGED( Crisis24_Admin__c ), Crisis24_Admin__c = FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Traveler Survey Opt-Out Checked</fullName>
        <actions>
            <name>Travel_Survey_Opt_Out</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Email to D2U of company opt-out for DT surveys on itins</description>
        <formula>Account.Travel_Survey_Opt_Out__c  = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Traveler Survey Opt-Out Un-Checked %28Opt-In%29</fullName>
        <actions>
            <name>Travel_Survey_Opt_Out_Un_checked_opt_in</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Email to D2U of company opting back in (previously opt-out) for DT surveys on itins</description>
        <formula>Account.Travel_Survey_Opt_Out__c  = FALSE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
