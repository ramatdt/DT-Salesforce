@isTest
private class OpportunityTriggerHandlerTest {

    @isTest
    static void testNewBusiness_USOnly() {
        Opportunity opp = new Opportunity(
            Name = 'Test New Business US',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Type = 'New Business',
            U_S_Air_Volume__c = 1000
        );

        insert opp;
        Opportunity inserted = [SELECT Amount, Calculated_Amount__c, Grand_Total_of_Global_Opportunity__c FROM Opportunity WHERE Id = :opp.Id];
    }

    @isTest
    static void testGlobalWithAllVolumes() {
        Opportunity opp = new Opportunity(
            Name = 'Test Global',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Type = 'Global',
            U_S_Air_Volume__c = 500,
            Canadian_Air_Volume__c = 0,
            ATPI_Air_Volume__c = 200,
            Non_ATPI_Agency_Air_Volume__c = 100
        );

        insert opp;
        Opportunity inserted = [SELECT Amount, Calculated_Amount__c, Grand_Total_of_Global_Opportunity__c FROM Opportunity WHERE Id = :opp.Id];
    }

    @isTest
    static void testUpSell() {
        Opportunity opp = new Opportunity(
            Name = 'Test Up-Sell',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Type = 'Up-Sell',
			Type_of_Upsell__c = 'Additional OBT Site(s)',
            Value_of_Up_Sell__c = 2500
        );

        insert opp;
        Opportunity inserted = [SELECT Amount, Calculated_Amount__c, Grand_Total_of_Global_Opportunity__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(2500, inserted.Amount);
        System.assertEquals(2500, inserted.Calculated_Amount__c);
        System.assertEquals(0, inserted.Grand_Total_of_Global_Opportunity__c);
    }

    @isTest
    static void testMeeting() {
        Opportunity opp = new Opportunity(
            Name = 'Test Meeting',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Type = 'Meeting',
            Estimated_Profit_Amount__c = 1800
        );

        insert opp;
        Opportunity inserted = [SELECT Amount, Calculated_Amount__c, Grand_Total_of_Global_Opportunity__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, inserted.Amount);
        System.assertEquals(0, inserted.Calculated_Amount__c);
        System.assertEquals(0, inserted.Grand_Total_of_Global_Opportunity__c);
    }

    @isTest
    static void testOtherTypeDefaultsToZero() {
        Opportunity opp = new Opportunity(
            Name = 'Test Other Type',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Type = 'Custom Type'
        );

        insert opp;
        Opportunity inserted = [SELECT Amount, Calculated_Amount__c, Grand_Total_of_Global_Opportunity__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, inserted.Amount);
        System.assertEquals(0, inserted.Calculated_Amount__c);
        System.assertEquals(0, inserted.Grand_Total_of_Global_Opportunity__c);
    }

    @isTest
    static void testNewBusinessValidationError() {
        Opportunity opp = new Opportunity(
            Name = 'Test Validation',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Type = 'New Business',
            U_S_Air_Volume__c = 500,
            Canadian_Air_Volume__c = 0
        );

        Test.startTest();
        try {
            insert opp;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('only one of U.S. Air Volume or Canadian Air Volume'), 'Expected error message not found');
        }
        Test.stopTest();
    }
}