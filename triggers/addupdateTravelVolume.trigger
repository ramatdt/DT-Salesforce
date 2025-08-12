/**
* To add the related Travel Volume to new Dk Travel Volume records. 
* Uses the MatchID (accountId + reportedMonth + reportedYear) to find the right Travel Volume
* 
*/

trigger addupdateTravelVolume on DK_Volume__c (before insert, before update, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        DKTravelVolumeTriggerHandler.updateTravelVolumeMapping(Trigger.new);
    }

    if (Trigger.isAfter) {
        DKTravelVolumeTriggerHandler handler = new DKTravelVolumeTriggerHandler();
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            handler.handleAfterEvents(Trigger.new, false);
        } else if (Trigger.isDelete) {
            handler.handleAfterEvents(Trigger.old, true);
        }
    }
}