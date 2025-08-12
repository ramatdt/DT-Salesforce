/**
 * Created by zacox on 5/11/24.
 */

public without sharing class SurveyController {

    @AuraEnabled(Cacheable=true)
    public static String getSurveyInfo(String responseId) {
        Survey__c survey = getSurvey(responseId);
        Survey_Response__c surveyResponse = getSurveyResponse(responseId);
        List<Survey_Question__c> questions = [
                SELECT Id, Name, Question_Type__c, Full_Question_Text__c, French_Question_Text__c
                FROM Survey_Question__c
                WHERE Survey__c =: survey.Id
                AND Legacy_SurveyQuestion_Id__c = NULL
        ];

        return JSON.serialize(new SurveyInfo(questions, surveyResponse));

    }

    private static Survey__c getSurvey(String responseId) {
        Survey_Response__c surveyResponse = [SELECT Survey__c FROM Survey_Response__c WHERE Id =: responseId];
        return [SELECT Id, Name, Description__c FROM Survey__c WHERE Id =: surveyResponse.Survey__c];
    }

    @AuraEnabled
    public static String submitNPSResponse(String responsesPayload, String surveyResponseId) {
        ResponseMap responseMap = (ResponseMap) JSON.deserialize(responsesPayload, ResponseMap.class);

        Survey_Response__c surveyResponse = getSurveyResponse(surveyResponseId);

        Survey_Question_Response__c questionResponse = new Survey_Question_Response__c(
                Survey_Response__c = surveyResponseId,
                Survey_Question__c = responseMap.questionId,
                Survey_Invitation__c = surveyResponse.Survey_Invitation__c,
                Text_Value__c = responseMap.responseValue,
                Number_Value__c = Decimal.valueOf(responseMap.responseValue),
                Data_Type__c = 'String',
                Response_Completion_DateTime__c = Datetime.now()
        );
        insert questionResponse;

        Survey_Invitation__c surveyInvitation = [SELECT Id FROM Survey_Invitation__c WHERE Id =: surveyResponse.Survey_Invitation__c];
        surveyInvitation.Overall_Survey_Response_Status__c = 'Completed';
        update surveyInvitation;

        surveyResponse.Status__c = 'Completed';
        surveyResponse.Completion_Date_Time__c = Datetime.now();
        update surveyResponse;

        return 'Success';
    }

    @AuraEnabled
    public static String submitResponses(String responsesPayload, String surveyResponseId) {
        QuestionResponses responses = (QuestionResponses) JSON.deserialize(responsesPayload, QuestionResponses.class);
        Survey_Response__c surveyResponse = getSurveyResponse(surveyResponseId);
        List<Survey_Question_Response__c> responsesToInsert = new List<Survey_Question_Response__c>();

        System.debug('responses: ' + JSON.serialize(responses));

        for(ResponseMap responseMap : responses.responses) {

            Survey_Question_Response__c questionResponse = new Survey_Question_Response__c(
                    Survey_Response__c = surveyResponseId,
                    Survey_Question__c = responseMap.questionId,
                    Survey_Invitation__c = surveyResponse.Survey_Invitation__c,
                    Data_Type__c = responseMap.dataType,
                    Response_Completion_DateTime__c = Datetime.now()
            );
            if(responseMap.dataType == 'String') {
                questionResponse.Text_Value__c = responseMap.responseValue;
            } else if(responseMap.dataType == 'Number') {
                questionResponse.Number_Value__c = Decimal.valueOf(responseMap.responseValue);
            } else if(responseMap.dataType == 'Boolean') {
                questionResponse.IsTrueorFalse__c = responseMap.responseValue == responseMap.responseValue;
                questionResponse.Text_Value__c = responseMap.responseValue;
            } else if(responseMap.dataType == 'Int') {
//                questionResponse.Date_Value__c = Date.valueOf(responseMap.responseValue);
            }
            responsesToInsert.add(questionResponse);
        }

        System.debug('responsesToInsert: ' + JSON.serialize(responsesToInsert));

        if(!responsesToInsert.isEmpty()) {
            insert responsesToInsert;
        }

        surveyResponse.Optional_Feedback_Status__c = 'Completed';
        update surveyResponse;

        return 'Success';
    }


    private static Survey_Response__c getSurveyResponse(String responseId) {
        Survey_Response__c surveyResponse = [
                SELECT Id, Survey__c, Language__c, Status__c, Survey_Invitation__c
                FROM Survey_Response__c
                WHERE Id =: responseId
        ];
        return surveyResponse;
    }

    public class ResponseMap {
        @AuraEnabled
        public String questionId { get; set; }
        @AuraEnabled
        public String responseValue { get; set; }
        @AuraEnabled
        public String dataType { get; set; }

        public ResponseMap(String questionId, String responseValue) {
            this.questionId = questionId;
            this.responseValue = responseValue;
            this.dataType = 'String;';
        }

        public ResponseMap(String questionId, String responseValue, String dataType) {
            this.questionId = questionId;
            this.responseValue = responseValue;
            this.dataType = dataType;
        }
    }

    public class QuestionResponses {
        @AuraEnabled
        public List<ResponseMap> responses  { get; set; }

        public QuestionResponses(List<ResponseMap> responses) {
            this.responses = responses;
        }
    }

    public class SurveyInfo {
        @AuraEnabled
        public List<Survey_Question__c> questions { get; set; }
        @AuraEnabled
        public Survey_Response__c surveyResponse { get; set; }

        public SurveyInfo(List<Survey_Question__c> questions, Survey_Response__c survey) {
            this.questions = questions;
            this.surveyResponse = survey;
        }
    }
}