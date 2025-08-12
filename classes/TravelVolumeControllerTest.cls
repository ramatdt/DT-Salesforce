@isTest
public class TravelVolumeControllerTest {
    
    //Not used as test setup because other negative testing methods require that no data should be created
    @isTest
    static void testGetTravelVolumeSummaryWithValidAccountId() {
        // Create mock data for travel volumes
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Travel_Volume__c travelVolume1 = new Travel_Volume__c(
            Account__c = testAccount.Id,
            Reported_Year__c = String.valueOf(Date.today().year()),
            Type__c = 'Core',
            Air_Spend_Total__c = 500.00,
            Car_Spend__c = 100.00,
            Hotel_Spend__c = 200.00,
            Air_Transactions__c = 5,
            Car_Days__c = 3,
            Hotel_Nights__c = 4,
            Air_Spend_Domestic__c = 300.00,
            Air_Spend_International__c = 200.00,
            Total_Trips__c = 10,
            Air_Spend_Transborder__c = 50.00
        );
        
        Travel_Volume__c travelVolume2 = new Travel_Volume__c(
            Account__c = testAccount.Id,
            Reported_Year__c = String.valueOf(Date.today().year() - 1),
            Type__c = 'Avenir',
            Air_Spend_Total__c = 400.00,
            Car_Spend__c = 150.00,
            Hotel_Spend__c = 250.00,
            Air_Transactions__c = 4,
            Car_Days__c = 2,
            Hotel_Nights__c = 5,
            Air_Spend_Domestic__c = 200.00,
            Air_Spend_International__c = 150.00,
            Total_Trips__c = 8,
            Air_Spend_Transborder__c = 30.00
        );
        
        insert new List<Travel_Volume__c>{travelVolume1, travelVolume2};
        
        // Call the method to be tested
        Test.startTest();
        TravelVolumeController.TravelVolumeSummary summary = TravelVolumeController.getTravelVolumeSummary(testAccount.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(summary, null, 'Summary should not be null');
        System.assertEquals(summary.currentYearCore.airSpendTotal, 500.00, 'Current year Core airSpendTotal mismatch');
        System.assertEquals(summary.currentYearCore.carSpend, 100.00, 'Current year Core carSpend mismatch');
        System.assertEquals(summary.previousYearAvenir.airSpendTotal, 400.00, 'Previous year Avenir airSpendTotal mismatch');
        System.assertEquals(summary.previousYearAvenir.carSpend, 150.00, 'Previous year Avenir carSpend mismatch');
        System.assertEquals(summary.currentYearCore.totalTrips, 10, 'Current year Core totalTrips mismatch');
    }

    @isTest
    static void testGetTravelVolumeSummaryWithBlankAccountId() {
        // Test for missing Account ID, should throw exception
        try {
            TravelVolumeController.getTravelVolumeSummary('');
            System.assert(false, 'Exception should have been thrown for blank account ID');
        } catch (AuraHandledException e) {
            System.assertEquals(e.getMessage(), 'Script-thrown exception', 'Exception message mismatch');
        }
    }

    @isTest
    static void testGetTravelVolumeSummaryWithNoTravelVolumeData() {
        // Create an account with no related travel volumes
        Account testAccount = new Account(Name = 'Test Account Without Data');
        insert testAccount;
        
        // Call the method to be tested
        Test.startTest();
        TravelVolumeController.TravelVolumeSummary summary = TravelVolumeController.getTravelVolumeSummary(testAccount.Id);
        Test.stopTest();
        
        // Verify that all values are zero when no data is present
        System.assertEquals(summary.currentYearCore.airSpendTotal, 0.00, 'Current year Core airSpendTotal mismatch when no data');
        System.assertEquals(summary.previousYearAvenir.carSpend, 0.00, 'Previous year Avenir carSpend mismatch when no data');
        System.assertEquals(summary.currentYearCore.totalTrips, 0, 'Current year Core totalTrips mismatch when no data');
    }
}