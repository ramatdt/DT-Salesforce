global class Batch_MonthlyTravelVolume implements Database.Batchable<SObject> {

    Date currentDate;
    String myMonth;
    String myYear;
    Date firstDayOfMonth;

    global Batch_MonthlyTravelVolume() {
        currentDate = Date.today();  // For current month
        Integer fullMonth = currentDate.month() + 100;
        myMonth = String.valueOf(fullMonth).right(2);
        myYear = String.valueOf(currentDate.year());
        firstDayOfMonth = Date.newInstance(currentDate.year(), currentDate.month(), 1);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Account
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acct : scope) {
            accountIds.add(acct.Id);
        }

        // Step 1: Query existing Travel Volume records for the current month/year
        Map<String, Boolean> existingKeys = new Map<String, Boolean>();
        for (Travel_Volume__c tv : [
            SELECT Account__c, Type__c
            FROM Travel_Volume__c
            WHERE Account__c IN :accountIds
            AND Reported_Month__c = :myMonth
            AND Reported_Year__c = :myYear
        ]) {
            String key = tv.Type__c + '-' + tv.Account__c;
            existingKeys.put(key, true);
        }

        // Step 2: Only add if record doesn't already exist
        List<Travel_Volume__c> objectList = new List<Travel_Volume__c>();
        for (Account account : scope) {
            for (String type : new List<String>{'Core', 'Avenir'}) {
                String key = type + '-' + account.Id;
                if (!existingKeys.containsKey(key)) {
                    objectList.add(new Travel_Volume__c(
                        Account__c = account.Id,
                        Reported_Month__c = myMonth,
                        Reported_Year__c = myYear,
                        First_Day_of_Month__c = firstDayOfMonth,
                        Type__c = type
                    ));
                }
            }
        }

        if (!objectList.isEmpty()) {
            insert objectList;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: Add logging or notifications if needed
    }
}