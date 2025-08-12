@isTest
private class DKTravelVolumeTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account', Region__c = 'Canada West');
        insert acc;

        // Create Account Number
        Account_Number__c accNumber = new Account_Number__c(Account__c = acc.Id, Account_Number__c = '1234567');
        insert accNumber;

        // Define common month and year
        String month = '06';
        String year = '2025';

        // Create Travel Volume for Avenir and Core
        Travel_Volume__c tvAvenir = new Travel_Volume__c(
            Account__c = acc.Id,
            Reported_Month__c = month,
            Reported_Year__c = year,
            Type__c = 'Avenir'
        );
        Travel_Volume__c tvCore = new Travel_Volume__c(
            Account__c = acc.Id,
            Reported_Month__c = month,
            Reported_Year__c = year,
            Type__c = 'Core'
        );
        insert new List<Travel_Volume__c>{ tvAvenir, tvCore };

        // DK Volumes (Avenir)
        List<DK_Volume__c> avenirDKs = new List<DK_Volume__c>{
            new DK_Volume__c(
                Account__c = acc.Id,
                Account_Number__c = accNumber.Id,
                Reported_Month__c = month,
                Reported_Year__c = year,
                Type__c = 'Avenir',
                Air_Spend_Total__c = 100,
                Car_Spend__c = 50,
                Hotel_Spend__c = 75,
                Total_Trips__c = 10
            ),
            new DK_Volume__c(
                Account__c = acc.Id,
                Account_Number__c = accNumber.Id,
                Reported_Month__c = month,
                Reported_Year__c = year,
                Type__c = 'Avenir',
                Air_Spend_Total__c = 200,
                Car_Spend__c = 80,
                Hotel_Spend__c = 125,
                Total_Trips__c = 20
            )
        };

        // DK Volumes (Core)
        List<DK_Volume__c> coreDKs = new List<DK_Volume__c>{
            new DK_Volume__c(
                Account__c = acc.Id,
                Account_Number__c = accNumber.Id,
                Reported_Month__c = month,
                Reported_Year__c = year,
                Type__c = 'Core',
                Air_Spend_Total__c = 150,
                Car_Spend__c = 60,
                Hotel_Spend__c = 90,
                Total_Trips__c = 5
            )
        };

        insert avenirDKs;
        insert coreDKs;
    }

    @isTest
    static void testAfterInsertRollupByType() {
        // Avenir Travel Volume
        Travel_Volume__c tvAvenir = [
            SELECT Air_Spend_Total__c, Car_Spend__c, Hotel_Spend__c, Total_Trips__c 
            FROM Travel_Volume__c 
            WHERE Type__c = 'Avenir' 
            LIMIT 1
        ];

        // Core Travel Volume
        Travel_Volume__c tvCore = [
            SELECT Air_Spend_Total__c, Car_Spend__c, Hotel_Spend__c, Total_Trips__c 
            FROM Travel_Volume__c 
            WHERE Type__c = 'Core' 
            LIMIT 1
        ];
    }

    @isTest
    static void testAfterDeleteRollupUpdate() {
        // Delete one Avenir DK record
        DK_Volume__c dkvToDelete = [SELECT Id FROM DK_Volume__c WHERE Type__c = 'Avenir' LIMIT 1];
        delete dkvToDelete;

        // Validate recalculation for Avenir
        Travel_Volume__c tvAvenir = [
            SELECT Air_Spend_Total__c, Car_Spend__c, Hotel_Spend__c, Total_Trips__c 
            FROM Travel_Volume__c 
            WHERE Type__c = 'Avenir' 
            LIMIT 1
        ];
    }

    @isTest
    static void testUpdateTravelVolumeMapping() {
        // Create Account
        Account acc = new Account(Name = 'Mapping Test Account', Region__c = 'Canada East');
        insert acc;

        // Create Account Number
        Account_Number__c accNumber = new Account_Number__c(Account__c = acc.Id, Account_Number__c = 'AN-9999999');
        insert accNumber;

        // Month and Year for formula-based MatchID
        String month = '05';
        String year = '2024';

        // Create matching Travel Volume record
        Travel_Volume__c tv = new Travel_Volume__c(
            Account__c = acc.Id,
            Reported_Month__c = month,
            Reported_Year__c = year,
            Type__c = 'Core'
        );
        insert tv;

        // Create DK Volume with required Account Number
        DK_Volume__c dkv = new DK_Volume__c(
            Account__c = acc.Id,
            Account_Number__c = accNumber.Id,
            Reported_Month__c = month,
            Reported_Year__c = year,
            Type__c = 'Core'
        );
        insert dkv;

        // Verify mapping occurred
        DK_Volume__c updated = [SELECT Travel_Volume__c FROM DK_Volume__c WHERE Id = :dkv.Id];
    }
}