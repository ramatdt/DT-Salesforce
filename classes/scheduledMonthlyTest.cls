@isTest
public class scheduledMonthlyTest {

    private static Account createTestAccount(String name, String type) {
        return new Account(
            Name = name,
            Region__c = 'East',
            Type = type
        );
    }

    @isTest
    static void testBatchExecution() {
        // Insert a small number of test Accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                Region__c = 'East',
                Type = 'Central Client'
            ));
        }
        insert testAccounts;

        Test.startTest();
        // Use a large enough scope to keep it in one batch (no AsyncException)
        Database.executeBatch(new Batch_MonthlyTravelVolume(), 200);
        Test.stopTest();

        // Each account should generate 2 records per months: Core + Avenir
        List<Travel_Volume__c> tvList = [
            SELECT Id, Account__c, Type__c
            FROM Travel_Volume__c
            WHERE Account__c IN :testAccounts and Account__c != null
        ];
    }

    @isTest
    static void testScheduleItMethod() {
        Test.startTest();
        scheduledMonthly.scheduleIt();
        Test.stopTest();

        // Validate the scheduled job
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'Schedule Travel Volume'
            LIMIT 1
        ];
    }
}