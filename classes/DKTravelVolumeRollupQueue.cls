// Queueable job to perform rollup on Travel Volume grouped by MatchID, Type, and Currency
public class DKTravelVolumeRollupQueue implements Queueable, Database.AllowsCallouts {
    private Set<String> matchTypeKeys;

    // Constructor accepts grouping keys (MatchID_Type_Currency)
    public DKTravelVolumeRollupQueue(Set<String> matchTypeKeys) {
        this.matchTypeKeys = matchTypeKeys;
    }

    // Executes the rollup logic asynchronously
    public void execute(QueueableContext context) {
        DKTravelVolumeTriggerHandler.updateTravelVolumeRollups(matchTypeKeys);
    }
}