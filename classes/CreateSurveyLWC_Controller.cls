/**
 * @author Samuel Prada, Rosetree Solutions
 * @website https://rosetreesolutions.com/
 * @email info@RosetreeSolutions.com
 * @phone (214) 731 - 7314
 * @date 05/20/23
 * @description This is a Salesforce Lightning Web Component Controller class. 
 */

 /**
 * @description This LWC controller class is responsible for creating surveys 
 * invitations and returning the link to the invitation.
 */
public without sharing class CreateSurveyLWC_Controller {

    private static Survey__c survey;
    private static Survey_Link__mdt surveyLinkConfig;
    private static Account account;

    private static final Map<String, String> languageMap = new Map<String, String>{
        'en' => 'English',
        'fr' => 'French'
    };

    
    /**
    * @description This method creates a survey invitation for a given 
    * account and returning the link to the invitation.
    * @param accountId String   
    * @param surveyName String
    * @param communityId String
    * @param language String
    * @return String         
    */
	@AuraEnabled
    public static String createSurvey(String accountId, String surveyName, String communityId, String language) {
        validateParameters(accountId,  surveyName,  communityId,  language);
        Survey_Invitation__c invitation = createSurveyInvitation(communityId);
        String surveyResponseId = createSurveyResponse(invitation.Id, language);
        
        // Redirect URL to survey with surveyResponseId
        return invitation.Invitation_Link__c + '?resp=' + surveyResponseId + '&lang=' + language;
    }

    private static void validateParameters(String accountId, String surveyName, String communityId, String language) {
        //Null parameter handling
        if (accountId == null) {
            throw new InvalidParameterException('Parameter \'accountId\' can not be null.');
        } else if(surveyName == null){
            throw new InvalidParameterException('Parameter \'surveyName\' can not be null.');
        } else if(communityId == null){
            throw new InvalidParameterException('Parameter \'communityId\' can not be null.');
        } else if(language == null){
            throw new InvalidParameterException('Parameter \'language\' can not be null.');
        }
        //Invalid parameter handling
        try{
            account = [SELECT Id, Name FROM Account WHERE Id =: accountId];
        } catch (Exception e){
            throw new InvalidParameterException('Invalid Account Id.');
        }
        
        try{
            survey = [SELECT Id, Name, Developer_Name__c FROM Survey__c WHERE Developer_Name__c =: surveyName];
        } catch (System.QueryException e) {
            throw new InvalidParameterException('Invalid Survey name.');
        }

        if(!language.equals('en') && !language.equals('fr')){
            throw new InvalidParameterException('Invalid language parameter.');
        }

        try{
            surveyLinkConfig = [
                    SELECT Language__c, Path__c, Sub_Domain__c
                    FROM Survey_Link__mdt
                    WHERE Survey__c =: survey.Name
                    AND Language__c =: languageMap.get(language)
                    LIMIT 1
            ];
        } catch (System.QueryException e) {
            throw new InvalidParameterException('Could not find Survey Link Config record.');
        }
    }

    private static Survey_Invitation__c createSurveyInvitation(Id communityId) {
        Survey_Invitation__c surveyInv = new Survey_Invitation__c();
        String invitationName = account.Name + ' ' + survey.Name + ' ' + Date.today().format();
        if(invitationName.length() > 80) {
            invitationName = invitationName.substring(0, 80);
        }
        surveyInv.Name = invitationName;
        surveyInv.Community_Id__c = communityId;
        surveyInv.Survey__c = survey.Id;
        surveyInv.Account__c = account.Id;
        surveyInv.Invitation_Link__c = generateSurveyInvitationLink();
        surveyInv.User_Id__c = UserInfo.getUserId();
        surveyInv.Overall_Survey_Response_Status__c = 'Started';
        insert surveyInv;

        return surveyInv;
    }

    private static String generateSurveyInvitationLink() {
        String surveyUrl = Url.getCurrentRequestUrl().toExternalForm();
        surveyUrl = surveyUrl.split('.com/')[0] + '.com/';
        surveyUrl += surveyLinkConfig.Sub_Domain__c + '/' + surveyLinkConfig.Path__c + '/';
        return surveyUrl;
    }

    private static String createSurveyResponse(Id invitationId, String language) {
        Survey_Response__c surveyResponse = new Survey_Response__c();
        surveyResponse.Survey_Invitation__c = invitationId;
        surveyResponse.Language__c = language == 'en' ? 'en_US' : 'fr_CA';
        surveyResponse.Status__c = 'Started';
        surveyResponse.Survey__c = survey.Id;
        insert surveyResponse;
        return surveyResponse.Id;
    }

    @TestVisible
    private class InvalidParameterException extends Exception {}
}