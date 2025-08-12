trigger TravelVolumeTrigger on Travel_Volume__c (before insert, before update) {
    if (Trigger.isBefore) {
        TravelVolumeTriggerHandler.normalizeReportedMonth(Trigger.new);
    }
}