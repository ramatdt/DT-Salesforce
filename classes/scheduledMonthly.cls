/**
* To schedule the monthly reconciliation:
*    NOTE: It should run at midnight on the first of every month on it's own, but if you make
*    changes and need to requeue run the command below from the developer's console
*
*    scheduledMonthly.scheduleIt();
*/

/**
* Updated the class now to RUN Daily and insert the Travel Volume for the Month if it is not available.
*
*/

global class scheduledMonthly implements Schedulable {
    global void execute(SchedulableContext sc) {
        Batch_MonthlyTravelVolume batch = new Batch_MonthlyTravelVolume();
        Database.executeBatch(batch, 200);
    }

    public static void scheduleIt() {
        String cronExp = '0 0 1 * * ?';
        System.schedule('Schedule Travel Volume', cronExp, new scheduledMonthly());
    }
}