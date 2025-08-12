/**
 * @author Samuel Prada, Rosetree Solutions
 * @website https://rosetreesolutions.com/
 * @email info@RosetreeSolutions.com
 * @phone (214) 731 - 7314
 * @date 06/04/23
 * @Description This is a class containing an invocable Apex method used for 
 * the mapping of Case fields triggered by SurveyResponse creation. 
 */

 /**
 * @Description This is a class containing an invocable Apex method used for 
 * the mapping of Case fields triggered by SurveyResponse creation. 
 */
public without sharing class MapSurveyQuestionToCaseInvocableApex {

    /**
    * @Description This method creates a shell Case with some fields mapped to it from Survey_Question_Response__c objects
    * and also creates a String to be mapped to the Subject field on Case.
    * @param arguments List<Arguments>   
    * @return List<Results>         
    */
    @InvocableMethod(Label='Populate shell Case and create Subject string')
    public static List<Results> mapSurveyQuestionsToCase(List<Arguments> arguments) {
        List<Survey_Question__c> surveyQuestionList = arguments.get(0).surveyQuestionList;
        Map<Id, Survey_Question__c> surveyQuestionsMap = new Map<Id, Survey_Question__c>(); 
        for (Survey_Question__c question : surveyQuestionList) {
            surveyQuestionsMap.put(question.Id, question);
        }

        Map<String, Survey_Question_Response__c> questionNameToSurveyQuestionResponse = new Map<String, Survey_Question_Response__c>();
        List<Survey_Question_Response__c> questionResponses = arguments.get(0).questionResponses;

        for (Survey_Question_Response__c sqr : questionResponses) {
            Survey_Question__c sq = surveyQuestionsMap.get(sqr.Survey_Question__c);
            questionNameToSurveyQuestionResponse.put(sq.Full_Question_Text__c, sqr);
        }

        Map<String, String> questionToFieldMap = new Map<String, String>();
        for (Survey_Question_To_Case_Mapping__mdt record : Survey_Question_To_Case_Mapping__mdt.getAll().values()) {
            questionToFieldMap.put(record.Survey_Question_Name__c, record.Case_Field__c);
        }

        Account account = [SELECT Name, Res_Center_Booking_Office__c FROM Account WHERE Id =: arguments.get(0).accountId];
        Case newCase = new Case(
            Subject = account.Res_Center_Booking_Office__c + ' ' + account.Name + ' Low Net Promoter Score'
        );
        for (String questionName : questionNameToSurveyQuestionResponse.keySet()) {

            //If Case field is not mapped, skip to next value
            if(questionToFieldMap.get(questionName) == null){
                continue;
            }

            Survey_Question_Response__c sqr = questionNameToSurveyQuestionResponse.get(questionName);
            String questionType = surveyQuestionsMap.get(sqr.Survey_Question__c).Question_Type__c;
            String responseDataType = sqr.Data_Type__c;

            if(questionType == 'NPS'){
                newCase.put(questionToFieldMap.get(questionName), questionNameToSurveyQuestionResponse.get(questionName).Number_Value__c);
            } else {
                newCase.put(questionToFieldMap.get(questionName), questionNameToSurveyQuestionResponse.get(questionName).Text_Value__c);
            }
        }

        Results response = new Results();
        response.outputCase = newCase;
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        
        return responseWrapper;
    }

    /**
    * @Description This inner class is a wrapper for the invocable apex's input parameters       
    */
    public class Arguments {
        @InvocableVariable(Label='AccountId' Description='Account Id to map to Case OwnerId' Required=true)
        public String accountId;
        @InvocableVariable(Label='Survey_Question_Response__c List' Description='List of Survey_Question_Response__c records' Required=true)
        public List<Survey_Question_Response__c> questionResponses;
        @InvocableVariable(Label='Survey_Question__c List' Description='List of Survey_Question__c records' Required=true)
        public List<Survey_Question__c> surveyQuestionList;
    }

    /**
    * @Description This inner class is a wrapper for the invocable apex's output parameters       
    */
    public class Results {
        @InvocableVariable(Label='Case for Output' Description='Mapped Case' Required=true)
        public Case outputCase;
    }
}