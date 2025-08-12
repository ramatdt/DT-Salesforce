/**
 * Created by zacox on 7/17/24.
 */

@IsTest
private class SurveyController_Test {

    @TestSetup
    static void setup() {
        // Create a Survey record
        Survey__c survey = new Survey__c(
                Name = 'Customer Satisfaction Survey',
                Description__c = 'A survey to gauge customer satisfaction.'
        );
        insert survey;

        // Create a Survey Invitation record and link it to the Survey
        Survey_Invitation__c invitation = new Survey_Invitation__c(
                Survey__c = survey.Id
        );
        insert invitation;

        // Create Survey Question records and link them to the Survey
        Survey_Question__c question1 = new Survey_Question__c(
                Survey__c = survey.Id,
                Name = 'Q1',
                Question_Type__c = 'FreeText',
                Full_Question_Text__c = 'How satisfied are you with our service?'
        );

        Survey_Question__c question2 = new Survey_Question__c(
                Survey__c = survey.Id,
                Name = 'Q2',
                Question_Type__c = 'FreeText',
                Full_Question_Text__c = 'Please provide any additional feedback.'
        );

        // Insert the Survey Question records
        insert new List<Survey_Question__c>{question1, question2};
    }

    @IsTest
    static void testGetSurveyInfo() {
        Survey_Response__c surveyResponse = new Survey_Response__c(
                Survey__c = [SELECT Id FROM Survey__c LIMIT 1].Id
        );
        insert surveyResponse;

        String surveyInfoJSON = SurveyController.getSurveyInfo(surveyResponse.Id);
        SurveyController.SurveyInfo info = (SurveyController.SurveyInfo) JSON.deserialize(surveyInfoJSON, SurveyController.SurveyInfo.class);

        System.assertEquals(2, info.questions.size());
        System.assertEquals(surveyResponse.Id, info.surveyResponse.Id);
    }

    @IsTest
    static void testSubmitNPSResponse() {
        Survey_Response__c surveyResponse = new Survey_Response__c(
                Survey__c = [SELECT Id FROM Survey__c LIMIT 1].Id,
                Survey_Invitation__c = [SELECT Id FROM Survey_Invitation__c LIMIT 1].Id
        );
        insert surveyResponse;

        Survey_Question__c question = new Survey_Question__c(
                Survey__c = [SELECT Id FROM Survey__c LIMIT 1].Id,
                Name = 'Q1',
                Question_Type__c = 'NPS',
                Full_Question_Text__c = 'How likely are you to recommend us to a friend?'
        );
        insert question;

        String responsesPayload = JSON.serialize(new SurveyController.ResponseMap(question.Id, '9'));
        SurveyController.submitNPSResponse(responsesPayload, surveyResponse.Id);

        Survey_Question_Response__c response = [
                SELECT Id, Survey_Question__c, Text_Value__c, Number_Value__c
                FROM Survey_Question_Response__c
                WHERE Survey_Response__c =: surveyResponse.Id
        ];

        System.assertEquals('9', response.Text_Value__c);
        System.assertEquals(9, response.Number_Value__c.intValue());
    }

    @IsTest
    static void testSubmitResponses() {
        Survey_Response__c surveyResponse = new Survey_Response__c(
                Survey__c = [SELECT Id FROM Survey__c LIMIT 1].Id,
                Survey_Invitation__c = [SELECT Id FROM Survey_Invitation__c LIMIT 1].Id
        );
        insert surveyResponse;

        Survey_Question__c question1 = new Survey_Question__c(
                Survey__c = [SELECT Id FROM Survey__c LIMIT 1].Id,
                Name = 'Q1',
                Question_Type__c = 'FreeText',
                Full_Question_Text__c = 'How satisfied are you with our service?'
        );

        Survey_Question__c question2 = new Survey_Question__c(
                Survey__c = [SELECT Id FROM Survey__c LIMIT 1].Id,
                Name = 'Q2',
                Question_Type__c = 'FreeText',
                Full_Question_Text__c = 'Please provide any additional feedback.'
        );

        insert new List<Survey_Question__c>{question1, question2};

        String responsesPayload = JSON.serialize(new SurveyController.QuestionResponses(
                new List<SurveyController.ResponseMap>{
                        new SurveyController.ResponseMap(question1.Id, 'Very satisfied', 'String'),
                        new SurveyController.ResponseMap(question2.Id, 'Great service!', 'String')
                }
        ));

        SurveyController.submitResponses(responsesPayload, surveyResponse.Id);

        List<Survey_Question_Response__c> responses = [
                SELECT Id, Survey_Question__c, Text_Value__c
                FROM Survey_Question_Response__c
                WHERE Survey_Response__c =: surveyResponse.Id
        ];

        System.assertEquals(2, responses.size());
        System.assertEquals('Very satisfied', responses[0].Text_Value__c);
        System.assertEquals('Great service!', responses[1].Text_Value__c);
    }
}