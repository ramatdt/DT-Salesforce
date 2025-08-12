@isTest
public class LeadHandlerTest {
    @isTest
    static void testCanadaRegionAssignment() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Canada',
            Company = 'Test Corp',
            Country = 'Canada',
            State = 'Ontario',
            Prospect_Spend_Air_Comment__c = 'Test'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead updatedLead = [SELECT Sales_Region__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Canada', updatedLead.Sales_Region__c, 'Sales Region should be Canada');
    }

    @isTest
    static void testUSEnterpriseRegion() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Enterprise',
            Company = 'Test Corp',
            Country = 'US',
            Prospect_Spend_Air__c = 5000000,
            State = 'NY'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
    }

    @isTest
    static void testUSMidMarketEast() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'East',
            Company = 'Test Corp',
            Country = 'US',
            Prospect_Spend_Air__c = 3000000,
            State = 'DC' 
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
    }

    @isTest
    static void testUSMidMarketWest() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'West',
            Company = 'Test Corp',
            Country = 'US',
            Prospect_Spend_Air__c = 3000000,
            State = 'CA'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
    }

    @isTest
    static void testUnmappedState() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Unmapped',
            Company = 'Test Corp',
            Country = 'US',
            Prospect_Spend_Air__c = 3000000,
            State = 'XX' 
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead updatedLead = [SELECT Sales_Region__c FROM Lead WHERE Id = :testLead.Id];
        System.assert(null == updatedLead.Sales_Region__c, 'Sales Region should be null for unmapped state');
    }

    @isTest
    static void testOtherCountry() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Other',
            Company = 'Test Corp',
            Country = 'Mexico',
            State = 'MX',
            Prospect_Spend_Air_Comment__c = 'Test'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead updatedLead = [SELECT Sales_Region__c FROM Lead WHERE Id = :testLead.Id];
        System.assert(null == updatedLead.Sales_Region__c, 'Sales Region should be null for non-US/Canada');
    }

    @isTest
    static void testRecursionPrevention() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Recursion',
            Company = 'Test Corp',
            Country = 'US',
            Prospect_Spend_Air__c = 3000000,
            State = 'DC'
        );
        
        insert testLead;

        Test.startTest();
        testLead.Prospect_Spend_Air__c = 5000000;
        update testLead;
        Test.stopTest();
    }

    @isTest
    static void testConvertedLead() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Convert',
            Company = 'Test Corp',
            Country = 'US',
            City = 'Test',
            PostalCode = '23435',
            Prospect_Spend_Air__c = 3000000,
            State = 'CA'
        );
        insert testLead;

        Test.startTest();
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(), 'Lead conversion should succeed');
        Test.stopTest();
    }
}