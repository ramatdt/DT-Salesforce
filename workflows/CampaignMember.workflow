<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_has_been_added_to_19_HubsSpot_campaign</fullName>
        <description>Contact has been added to 19-HubsSpot campaign</description>
        <protected>false</protected>
        <recipients>
            <recipient>gzappa@dt.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Contact_added_to_20_HubSpot_Campaign</template>
    </alerts>
    <alerts>
        <fullName>Contact_has_been_added_to_20_HubSpot_Campaign</fullName>
        <description>Contact has been added to 20-HubSpot Campaign</description>
        <protected>false</protected>
        <recipients>
            <recipient>gzappa@dt.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Contact_added_to_20_HubSpot_Campaign</template>
    </alerts>
    <rules>
        <fullName>Contact added to 19-HubSpot</fullName>
        <actions>
            <name>Contact_has_been_added_to_19_HubsSpot_campaign</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>19-HubSpot</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>1/1/2019</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Contact added to 20-HubSpot</fullName>
        <actions>
            <name>Contact_has_been_added_to_20_HubSpot_Campaign</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>20-HubSpot</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>1/1/2020</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
