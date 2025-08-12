//Objects associated with Surveys are not writeable and seeAllData=true must be used.
@IsTest(SeeAllData=true)
public class CreateSurveyLWC_Controller_Test {

    static void setup() {
        List<Survey__c> clientTravelerSurvey = [SELECT Id FROM Survey__c WHERE Developer_Name__c = 'client_traveler_survey' LIMIT 1];

        if(clientTravelerSurvey.size() == 0) {
            // Create a Survey record
            Survey__c survey = new Survey__c(
                    Name = 'Client Traveler Survey',
                    Developer_Name__c = 'client_traveler_survey',
                    Description__c = 'A survey to gauge customer satisfaction.'
            );
            insert survey;
        }

    }

	@IsTest
    static void createSurveySuccessTest() {
        setup();
        Account testAccount = new Account(
        	Name = 'Test Account',
            Region__c = 'East'
        );
        insert testAccount;
        
        Survey__c survey = [SELECT Id, Developer_Name__c, Name FROM Survey__c WHERE Developer_Name__c = 'client_traveler_survey' LIMIT 1];
        System.assert(survey.Id != null);
        Network community = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = 'ENGSurvey'];
		System.assert(community.Id != null);
        
		Test.startTest();
        	String surveyURL = CreateSurveyLWC_Controller.createSurvey(testAccount.Id, survey.Developer_Name__c, community.Id, 'en');
        Test.stopTest();
        
        Survey_Invitation__c createdInvitation = [SELECT Id, Account__c, Survey__c, Community_Id__c FROM Survey_Invitation__c WHERE Account__c =: testAccount.Id];
        System.assert(createdInvitation.Id != null);
        System.assert(createdInvitation.Community_Id__c == community.Id);
        System.assert(createdInvitation.Survey__c == survey.Id);
    }

    @IsTest
    static void testCreateSurveyNoAccountId() {
        setup();

        Survey__c survey = [SELECT Id, Developer_Name__c, Name FROM Survey__c WHERE Developer_Name__c = 'client_traveler_survey' LIMIT 1];
        System.assert(survey.Id != null);
        Network community = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = 'ENGSurvey'];
		System.assert(community.Id != null);

        Test.startTest();
        Exception actualException;
        try {
            CreateSurveyLWC_Controller.createSurvey(null, survey.Developer_Name__c, community.Id, 'en');
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();

        System.assert(
            actualException instanceof CreateSurveyLWC_Controller.InvalidParameterException, 
            'Exception type should be InvalidParameterException'
        );
        System.assertEquals(
            'Parameter \'accountId\' can not be null.', 
            actualException.getMessage()
        );
    }

    @IsTest
    static void testCreateSurveyNoSurveyName() {
        Account testAccount = new Account(
        	Name = 'Test Account',
            Region__c = 'East'
        );
        insert testAccount;

        Network community = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = 'ENGSurvey'];
		System.assert(community.Id != null);
        
        Test.startTest();
        Exception actualException;
        try {
            CreateSurveyLWC_Controller.createSurvey(testAccount.Id, null, community.Id, 'en');
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();

        System.assert(
            actualException instanceof CreateSurveyLWC_Controller.InvalidParameterException, 
            'Exception type should be InvalidParameterException'
        );
        System.assertEquals(
            'Parameter \'surveyName\' can not be null.', 
            actualException.getMessage()
        );
    }

    @IsTest
    static void testCreateSurveyNoCommunityId() {
        setup();

        Account testAccount = new Account(
        	Name = 'Test Account',
            Region__c = 'East'
        );
        insert testAccount;

        Survey__c testSurvey = [SELECT Id, Developer_Name__c, Name FROM Survey__c WHERE Developer_Name__c = 'client_traveler_survey' LIMIT 1];
        System.assert(testSurvey.Id != null);

        Test.startTest();
        Exception actualException;
        try {
            CreateSurveyLWC_Controller.createSurvey(testAccount.Id, testSurvey.Developer_Name__c, null, 'en');
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();

        System.assert(
            actualException instanceof CreateSurveyLWC_Controller.InvalidParameterException, 
            'Exception type should be InvalidParameterException'
        );
        System.assertEquals(
            'Parameter \'communityId\' can not be null.', 
            actualException.getMessage()
        );    
    }

    @IsTest
    static void testCreateSurveyNoLanguageParameter() {
        setup();

        Account testAccount = new Account(
        	Name = 'Test Account',
            Region__c = 'East'
        );
        insert testAccount;

        Survey__c survey = [SELECT Id, Developer_Name__c, Name FROM Survey__c WHERE Developer_Name__c = 'client_traveler_survey' LIMIT 1];
        System.assert(survey.Id != null);
        Network community = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = 'ENGSurvey'];
		System.assert(community.Id != null);
        
        Test.startTest();
        Exception actualException;
        try {
            CreateSurveyLWC_Controller.createSurvey(testAccount.Id, survey.Developer_Name__c, community.Id, null);
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();

        System.assert(
            actualException instanceof CreateSurveyLWC_Controller.InvalidParameterException, 
            'Exception type should be InvalidParameterException'
        );
        System.assertEquals(
            'Parameter \'language\' can not be null.', 
            actualException.getMessage()
        );
    }

    @IsTest
    static void testCreateSurveyInvalidSurveyName() {
        Account testAccount = new Account(
        	Name = 'Test Account',
            Region__c = 'East'
        );
        insert testAccount;

        Network community = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = 'ENGSurvey'];
		System.assert(community.Id != null);
        
        Test.startTest();
        Exception actualException;
        try {
            CreateSurveyLWC_Controller.createSurvey(testAccount.Id, 'testDummyBadParameter', community.Id, 'en');
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();

        System.assert(
            actualException instanceof CreateSurveyLWC_Controller.InvalidParameterException, 
            'Exception type should be InvalidParameterException'
        );
        System.assertEquals(
            'Invalid Survey name.',
            actualException.getMessage()
        );
    }

    @IsTest
    static void testCreateSurveyInvalidAccountId() {
        setup();

        Survey__c survey = [SELECT Id, Developer_Name__c, Name FROM Survey__c WHERE Developer_Name__c = 'client_traveler_survey' LIMIT 1];
        System.assert(survey.Id != null);
        Network community = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = 'ENGSurvey'];
		System.assert(community.Id != null);
        
        Test.startTest();
        Exception actualException;
        try {
            CreateSurveyLWC_Controller.createSurvey('INVALIDID', survey.Developer_Name__c, community.Id, 'en');
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();

        System.assert(
            actualException instanceof CreateSurveyLWC_Controller.InvalidParameterException, 
            'Exception type should be InvalidParameterException'
        );
        System.assertEquals(
            'Invalid Account Id.', 
            actualException.getMessage()
        );
    }

    @IsTest
    static void testCreateSurveyInvalidLanguageParameter() {
        setup();

        Account testAccount = new Account(
        	Name = 'Test Account',
            Region__c = 'East'
        );
        insert testAccount;

        Survey__c survey = [SELECT Id, Developer_Name__c, Name FROM Survey__c WHERE Developer_Name__c = 'client_traveler_survey' LIMIT 1];
        System.assert(survey.Id != null);
        Network community = [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix = 'ENGSurvey'];
		System.assert(community.Id != null);
        
        Test.startTest();
        Exception actualException;
        try {
            CreateSurveyLWC_Controller.createSurvey(testAccount.Id, survey.Developer_Name__c, community.Id, 't');
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();

        System.assert(
            actualException instanceof CreateSurveyLWC_Controller.InvalidParameterException, 
            'Exception type should be InvalidParameterException'
        );
        System.assertEquals(
            'Invalid language parameter.', 
            actualException.getMessage()
        );
    }
}