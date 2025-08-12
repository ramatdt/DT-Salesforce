<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACCOUNT_Travel_Survey_Opt_Out</fullName>
        <ccEmails>Direct2U@dt.com</ccEmails>
        <description>ACCOUNT Travel Survey Opt Out</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Traveler_Survey_Opt_Out_Checked</template>
    </alerts>
    <alerts>
        <fullName>ACTION_REQUIRED_COLA_Clause_Renewal_is_in_90_Days</fullName>
        <ccEmails>jhedrick@dt.com, mnelson@dt.com, salesforcesupport@dt.com, kdelpo@dt.com, ssaunders@dt.com</ccEmails>
        <description>ACTION REQUIRED: COLA Clause Renewal is in 90 Days</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Account_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/COLA_Annual_Effective_Date_Approaching</template>
    </alerts>
    <alerts>
        <fullName>ACTION_REQUIRED_Contract_End_Date_Approaching</fullName>
        <ccEmails>jhedrick@dt.com, mnelson@dt.com, salesforcesupport@dt.com, kdelpo@dt.com, ssaunders@dt.com</ccEmails>
        <description>ACTION REQUIRED: Contract End Date Approaching</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Account_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Acct_Contract_End_Date_Approaching</template>
    </alerts>
    <alerts>
        <fullName>ACTION_REQUIRED_Direct_Select_Contract_End_Date_Approaching</fullName>
        <ccEmails>salesforcesupport@dt.com</ccEmails>
        <description>ACTION REQUIRED: Direct Select Contract End Date Approaching</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Acct_Contract_End_Date_Approaching</template>
    </alerts>
    <alerts>
        <fullName>Crisis24_GardaWorld_Changed</fullName>
        <ccEmails>productsupport@dt.com</ccEmails>
        <ccEmails>salesforcesupport@dt.com</ccEmails>
        <description>Crisis24/GardaWorld is changed on current client Types</description>
        <protected>false</protected>
        <senderAddress>noreply@dt.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Crisis24_GardaWorld_Changed</template>
    </alerts>
</Workflow>
