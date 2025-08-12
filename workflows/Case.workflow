<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_to_Case_Owner_and_Watchers</fullName>
        <description>Send Email to Case Owner and Watchers</description>
        <protected>false</protected>
        <recipients>
            <recipient>gzappa@dt.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SUPPORTNewassignmentnotificationSAMPLE</template>
    </alerts>
    <rules>
        <fullName>Email Alert</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.CaseNumber</field>
            <operation>contains</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason</field>
            <operation>contains</operation>
            <value>Customer Service - Traditional,Customer Service - OBT,Implementation,Profiles,Account Mgmt.,Quality Control,Invoicing/Refunds/Overcharge,Compleat,MIS,Scripts,Vendor - Air,Vendor - Hotel,Vendor - Car Rental,Vendor - Others,Concur,Nutravel,D</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>contains</operation>
            <value>High,Medium,Low</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
