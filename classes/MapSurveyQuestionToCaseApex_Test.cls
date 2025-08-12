@IsTest
private class MapSurveyQuestionToCaseApex_Test {

    @TestSetup 
    static void setup() {
        Account acct = new Account(
            Res_Center_Booking_Office__c = 'San Francisco;Atlanta', Name = 'TestAcct', Region__c = 'East'
        );
        insert acct;
    }

    @IsTest
    static void testMethodResponseCreatedCorrectly(){
        //List<Survey_Question_Response__c> JSON String 
        String sqrListJsonString =  '[{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMJCA2"},' + 
                                    '"Id":"0Kr010000004EMJCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY8CAK","Text_Value__c":"I acknowledge"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMKCA2"},' + 
                                    '"Id":"0Kr010000004EMKCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY4CAK","Number_Value__c":1,"Text_Value__c":"1"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMLCA2"},' +
                                    '"Id":"0Kr010000004EMLCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY6CAK","Text_Value__c":"Mike Masters"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMMCA2"},' +
                                    '"Id":"0Kr010000004EMMCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY5CAK","Text_Value__c":"Nothing"},' +
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMNCA2"},' +
                                    '"Id":"0Kr010000004EMNCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY3CAK","Text_Value__c":"Low Score, Email Provided"},' +
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMOCA2"},' +
                                    '"Id":"0Kr010000004EMOCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY7CAK","Text_Value__c":"t@t.com"}]';
        //List<Survey_Question__c> JSON String 
        String sqListJsonString =   '[{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY3CAK"},"Id":"0Ku01000000CgY3CAK",' +
                                    '"Full_Question_Text__c":"How was your reservation experience?"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY4CAK"},"Id":"0Ku01000000CgY4CAK",' +
                                    '"Full_Question_Text__c":"How likely are you to recommend our services to a colleague?","Question_Type__c":"NPS"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY5CAK"},"Id":"0Ku01000000CgY5CAK",' +
                                    '"Full_Question_Text__c":"Thank you for taking the time to complete this survey. We truly appreciate your feedback, if there are any other comments you ' +
                                    'would like to add we would love to hear from you."},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY6CAK"},"Id":"0Ku01000000CgY6CAK",' +
                                    '"Full_Question_Text__c":"If you would like us to contact you, please provide your  first and last name below:"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY7CAK"},"Id":"0Ku01000000CgY7CAK",' +
                                    '"Full_Question_Text__c":"If you would like us to contact you, please provide your  email address below:"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY8CAK"},"Id":"0Ku01000000CgY8CAK",' +
                                    '"Full_Question_Text__c":"‘Data protection: Direct Travel will never release your personal details to any company outside Direct Travel for mailing or ' +
                                    'marketing purposes. In this instance, personal details are used for the purposes of collecting feedback on the service you received from ' +
                                    'Direct Travel. Please see our privacy policy at  Privacy &#124; Direct Travel (dt.com) .’"}]';
        MapSurveyQuestionToCaseInvocableApex.Arguments arguments = new MapSurveyQuestionToCaseInvocableApex.Arguments();
        Account account = [SELECT Id, Res_Center_Booking_Office__c, Name FROM Account LIMIT 1];
        arguments.accountId = account.Id;
        arguments.surveyQuestionList = (List<Survey_Question__c>) JSON.deserialize(sqListJsonString, List<Survey_Question__c>.class);
        arguments.questionResponses = (List<Survey_Question_Response__c>) JSON.deserialize(sqrListJsonString, List<Survey_Question_Response__c>.class);
        List<MapSurveyQuestionToCaseInvocableApex.Arguments> argumentsWrapper= new List<MapSurveyQuestionToCaseInvocableApex.Arguments>();
        argumentsWrapper.add(arguments);
        

        Test.startTest();
        List<MapSurveyQuestionToCaseInvocableApex.Results> results = MapSurveyQuestionToCaseInvocableApex.mapSurveyQuestionsToCase(argumentsWrapper);
        Test.stopTest();

        System.assertEquals(1, results.get(0).outputCase.How_likely_to_recommend_services__c);
//        System.assertEquals('t@t.com', results.get(0).outputCase.Respondent_Email__c);
//        System.assertEquals('Mike Masters', results.get(0).outputCase.Respondent_Name__c);
//        System.assertEquals('Nothing', results.get(0).outputCase.Other_comments__c);
//        System.assertEquals('Low Score, Email Provided', results.get(0).outputCase.How_was_your_reservation_experience__c);
        System.assertEquals(account.Res_Center_Booking_Office__c + ' ' + account.Name + ' Low Net Promoter Score', results.get(0).outputCase.Subject);
    }

    @IsTest
    static void testNoAccountIdPassedToInvocableMethod(){
        //List<Survey_Question_Response__c> JSON String 
        String sqrListJsonString =  '[{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMJCA2"},' + 
                                    '"Id":"0Kr010000004EMJCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY8CAK","Text_Value__c":"I acknowledge"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMKCA2"},' + 
                                    '"Id":"0Kr010000004EMKCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY4CAK","Number_Value__c":1,"Text_Value__c":"1"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMLCA2"},' +
                                    '"Id":"0Kr010000004EMLCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY6CAK","Text_Value__c":"Mike Masters"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMMCA2"},' +
                                    '"Id":"0Kr010000004EMMCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY5CAK","Text_Value__c":"Nothing"},' +
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMNCA2"},' +
                                    '"Id":"0Kr010000004EMNCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY3CAK","Text_Value__c":"Low Score, Email Provided"},' +
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMOCA2"},' +
                                    '"Id":"0Kr010000004EMOCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY7CAK","Text_Value__c":"t@t.com"}]';
        //List<Survey_Question__c> JSON String 
        String sqListJsonString =   '[{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY3CAK"},"Id":"0Ku01000000CgY3CAK",' +
                                    '"Full_Question_Text__c":"How was your reservation experience?"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY4CAK"},"Id":"0Ku01000000CgY4CAK",' +
                                    '"Full_Question_Text__c":"How likely are you to recommend our services to a colleague?","Question_Type__c":"NPS"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY5CAK"},"Id":"0Ku01000000CgY5CAK",' +
                                    '"Full_Question_Text__c":"Thank you for taking the time to complete this survey. We truly appreciate your feedback, if there are any other comments you ' +
                                    'would like to add we would love to hear from you."},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY6CAK"},"Id":"0Ku01000000CgY6CAK",' +
                                    '"Full_Question_Text__c":"If you would like us to contact you, please provide your  first and last name below:"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY7CAK"},"Id":"0Ku01000000CgY7CAK",' +
                                    '"Full_Question_Text__c":"If you would like us to contact you, please provide your  email address below:"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY8CAK"},"Id":"0Ku01000000CgY8CAK",' +
                                    '"Full_Question_Text__c":"‘Data protection: Direct Travel will never release your personal details to any company outside Direct Travel for mailing or ' +
                                    'marketing purposes. In this instance, personal details are used for the purposes of collecting feedback on the service you received from ' +
                                    'Direct Travel. Please see our privacy policy at  Privacy &#124; Direct Travel (dt.com) .’"}]';
        MapSurveyQuestionToCaseInvocableApex.Arguments arguments = new MapSurveyQuestionToCaseInvocableApex.Arguments();
        arguments.surveyQuestionList = (List<Survey_Question__c>) JSON.deserialize(sqListJsonString, List<Survey_Question__c>.class);
        arguments.questionResponses = (List<Survey_Question_Response__c>) JSON.deserialize(sqrListJsonString, List<Survey_Question_Response__c>.class);
        List<MapSurveyQuestionToCaseInvocableApex.Arguments> argumentsWrapper= new List<MapSurveyQuestionToCaseInvocableApex.Arguments>();
        argumentsWrapper.add(arguments);
        
        try {
            Test.startTest();
            List<MapSurveyQuestionToCaseInvocableApex.Results> results = MapSurveyQuestionToCaseInvocableApex.mapSurveyQuestionsToCase(argumentsWrapper);
            Test.stopTest();
        } catch (System.QueryException e) {
            System.assert(e != null);
        }
    }

    @IsTest
    static void testNoSurveyQuestionResponseListPassedToInvocableMethod(){
        //List<Survey_Question__c> JSON String 
        String sqListJsonString =   '[{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY3CAK"},"Id":"0Ku01000000CgY3CAK",' +
                                    '"Full_Question_Text__c":"How was your reservation experience?"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY4CAK"},"Id":"0Ku01000000CgY4CAK",' +
                                    '"Full_Question_Text__c":"How likely are you to recommend our services to a colleague?","Question_Type__c":"NPS"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY5CAK"},"Id":"0Ku01000000CgY5CAK",' +
                                    '"Full_Question_Text__c":"Thank you for taking the time to complete this survey. We truly appreciate your feedback, if there are any other comments you ' +
                                    'would like to add we would love to hear from you."},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY6CAK"},"Id":"0Ku01000000CgY6CAK",' +
                                    '"Full_Question_Text__c":"If you would like us to contact you, please provide your  first and last name below:"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY7CAK"},"Id":"0Ku01000000CgY7CAK",' +
                                    '"Full_Question_Text__c":"If you would like us to contact you, please provide your  email address below:"},' +
                                    '{"attributes":{"type":"Survey_Question__c","url":"/services/data/v58.0/sobjects/Survey_Question__c/0Ku01000000CgY8CAK"},"Id":"0Ku01000000CgY8CAK",' +
                                    '"Full_Question_Text__c":"‘Data protection: Direct Travel will never release your personal details to any company outside Direct Travel for mailing or ' +
                                    'marketing purposes. In this instance, personal details are used for the purposes of collecting feedback on the service you received from ' +
                                    'Direct Travel. Please see our privacy policy at  Privacy &#124; Direct Travel (dt.com) .’"}]';
        MapSurveyQuestionToCaseInvocableApex.Arguments arguments = new MapSurveyQuestionToCaseInvocableApex.Arguments();
        arguments.surveyQuestionList = (List<Survey_Question__c>) JSON.deserialize(sqListJsonString, List<Survey_Question__c>.class);
        List<MapSurveyQuestionToCaseInvocableApex.Arguments> argumentsWrapper= new List<MapSurveyQuestionToCaseInvocableApex.Arguments>();
        argumentsWrapper.add(arguments);
        
        try {
            Test.startTest();
            List<MapSurveyQuestionToCaseInvocableApex.Results> results = MapSurveyQuestionToCaseInvocableApex.mapSurveyQuestionsToCase(argumentsWrapper);
            Test.stopTest();
        } catch (System.NullPointerException e) {
            System.assert(e != null);
        }
    }

    @IsTest
    static void testNosurveyQuestionListPassedToInvocableMethod(){
        //List<Survey_Question_Response__c> JSON String 
        String sqrListJsonString =  '[{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMJCA2"},' + 
                                    '"Id":"0Kr010000004EMJCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY8CAK","Text_Value__c":"I acknowledge"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMKCA2"},' + 
                                    '"Id":"0Kr010000004EMKCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY4CAK","Number_Value__c":1,"Text_Value__c":"1"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMLCA2"},' +
                                    '"Id":"0Kr010000004EMLCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY6CAK","Text_Value__c":"Mike Masters"},' + 
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMMCA2"},' +
                                    '"Id":"0Kr010000004EMMCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY5CAK","Text_Value__c":"Nothing"},' +
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMNCA2"},' +
                                    '"Id":"0Kr010000004EMNCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY3CAK","Text_Value__c":"Low Score, Email Provided"},' +
                                    '{"attributes":{"type":"Survey_Question_Response__c","url":"/services/data/v58.0/sobjects/Survey_Question_Response__c/0Kr010000004EMOCA2"},' +
                                    '"Id":"0Kr010000004EMOCA2","Legacy_Response_Id__c__c":"0My010000004ExMCAU","Survey_Question__c":"0Ku01000000CgY7CAK","Text_Value__c":"t@t.com"}]';
        MapSurveyQuestionToCaseInvocableApex.Arguments arguments = new MapSurveyQuestionToCaseInvocableApex.Arguments();
        arguments.questionResponses = (List<Survey_Question_Response__c>) JSON.deserialize(sqrListJsonString, List<Survey_Question_Response__c>.class);
        List<MapSurveyQuestionToCaseInvocableApex.Arguments> argumentsWrapper= new List<MapSurveyQuestionToCaseInvocableApex.Arguments>();
        argumentsWrapper.add(arguments);
        
        try {
            Test.startTest();
            List<MapSurveyQuestionToCaseInvocableApex.Results> results = MapSurveyQuestionToCaseInvocableApex.mapSurveyQuestionsToCase(argumentsWrapper);
            Test.stopTest();
        } catch (System.NullPointerException e) {
            System.assert(e != null);
        }
    }
}