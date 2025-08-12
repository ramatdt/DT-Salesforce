/** Queueable job to update the Type field on Travel Volume records
* Based on the latest DK Volume data per Account
*/

public class DKTravelVolumeTypeUpdateQueue implements Queueable {
    private Set<Id> accountIds;

    // Constructor accepts a set of Account Ids to process
    public DKTravelVolumeTypeUpdateQueue(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }

    // Executes type update logic asynchronously
    public void execute(QueueableContext context) {
        DKTravelVolumeTriggerHandler.updateTravelVolumeTypes(accountIds);
    }
}