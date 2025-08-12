public with sharing class DKTravelVolumeTriggerHandler {
    public void handleAfterEvents(List<DK_Volume__c> records, Boolean isDelete) {
        Set<String> matchTypeKeys = new Set<String>();
        Set<Id> accountIds = new Set<Id>();

        for (DK_Volume__c dkv : records) {
            if (dkv.MatchID__c != null && dkv.Type__c != null) {
                matchTypeKeys.add(dkv.MatchID__c + '_' + dkv.Type__c);
            }
            if (dkv.Account__c != null) {
                accountIds.add(dkv.Account__c);
            }
        }

        if (!matchTypeKeys.isEmpty()) {
            System.enqueueJob(new DKTravelVolumeRollupQueue(matchTypeKeys));
        }

        if (!accountIds.isEmpty()) {
            System.enqueueJob(new DKTravelVolumeTypeUpdateQueue(accountIds));
        }
    }

    public static void updateTravelVolumeRollups(Set<String> matchTypeKeys) {
        Map<String, List<DK_Volume__c>> groupedDKVolumes = new Map<String, List<DK_Volume__c>>();
        Map<String, String> matchTypeCurrencyMap = new Map<String, String>();
        Set<String> matchIds = new Set<String>();

        for (String key : matchTypeKeys) {
            groupedDKVolumes.put(key, new List<DK_Volume__c>());
            matchIds.add(key.split('_')[0]);
        }

        List<DK_Volume__c> dkVolumes = [
            SELECT MatchID__c, Type__c, Air_Spend_Total__c, Car_Spend__c, Hotel_Spend__c,
                   Air_Transactions__c, Car_Days__c, Hotel_Nights__c, OBT_Adoption__c,
                   Air_Spend_Domestic__c, Air_Spend_International__c, Total_Trips__c,
                   Air_Spend_Transborder__c, CurrencyIsoCode
            FROM DK_Volume__c
            WHERE MatchID__c IN :matchIds AND Type__c != null
        ];

        for (DK_Volume__c dkv : dkVolumes) {
            String key = dkv.MatchID__c + '_' + dkv.Type__c;
            if (groupedDKVolumes.containsKey(key)) {
                groupedDKVolumes.get(key).add(dkv);

                // Track currency for this group (assumes same currency per group)
                if (!matchTypeCurrencyMap.containsKey(key)) {
                    matchTypeCurrencyMap.put(key, dkv.CurrencyIsoCode);
                }
            }
        }

        Map<String, Travel_Volume__c> travelVolumeMap = new Map<String, Travel_Volume__c>();
        for (Travel_Volume__c tv : [
            SELECT Id, MatchID__c, Type__c, CurrencyIsoCode
            FROM Travel_Volume__c
            WHERE MatchID__c IN :matchIds AND Type__c != null
        ]) {
            String key = tv.MatchID__c + '_' + tv.Type__c;
            travelVolumeMap.put(key, tv);
        }

        List<Travel_Volume__c> toUpdate = new List<Travel_Volume__c>();

        for (String key : groupedDKVolumes.keySet()) {
            if (!travelVolumeMap.containsKey(key)) continue;

            Travel_Volume__c tv = travelVolumeMap.get(key);
            List<DK_Volume__c> volumes = groupedDKVolumes.get(key);

            tv.Air_Spend_Total__c = 0;
            tv.Car_Spend__c = 0;
            tv.Hotel_Spend__c = 0;
            tv.Air_Transactions__c = 0;
            tv.Car_Days__c = 0;
            tv.Hotel_Nights__c = 0;
            tv.OBT_Adoption__c = 0;
            tv.Air_Spend_Domestic__c = 0;
            tv.Air_Spend_International__c = 0;
            tv.Air_Spend_Transborder__c = 0;
            tv.Total_Trips__c = 0;

            // Set or update the currency code
            if (matchTypeCurrencyMap.containsKey(key)) {
                String dkCurrency = matchTypeCurrencyMap.get(key);
                if (dkCurrency != null && tv.CurrencyIsoCode != dkCurrency) {
                    tv.CurrencyIsoCode = dkCurrency;
                }
            }

            for (DK_Volume__c dkv : volumes) {
                tv.Air_Spend_Total__c += dkv.Air_Spend_Total__c != null ? dkv.Air_Spend_Total__c : 0;
                tv.Car_Spend__c += dkv.Car_Spend__c != null ? dkv.Car_Spend__c : 0;
                tv.Hotel_Spend__c += dkv.Hotel_Spend__c != null ? dkv.Hotel_Spend__c : 0;
                tv.Air_Transactions__c += dkv.Air_Transactions__c != null ? dkv.Air_Transactions__c : 0;
                tv.Car_Days__c += dkv.Car_Days__c != null ? dkv.Car_Days__c : 0;
                tv.Hotel_Nights__c += dkv.Hotel_Nights__c != null ? dkv.Hotel_Nights__c : 0;
                tv.OBT_Adoption__c += dkv.OBT_Adoption__c != null ? dkv.OBT_Adoption__c : 0;
                tv.Air_Spend_Domestic__c += dkv.Air_Spend_Domestic__c != null ? dkv.Air_Spend_Domestic__c : 0;
                tv.Air_Spend_International__c += dkv.Air_Spend_International__c != null ? dkv.Air_Spend_International__c : 0;
                tv.Air_Spend_Transborder__c += dkv.Air_Spend_Transborder__c != null ? dkv.Air_Spend_Transborder__c : 0;
                tv.Total_Trips__c += dkv.Total_Trips__c != null ? dkv.Total_Trips__c : 0;
            }

            toUpdate.add(tv);
        }

        if (!toUpdate.isEmpty()) {
            try {
                update toUpdate;
            } catch (Exception e) {
                System.debug('Error updating Travel Volume rollups: ' + e.getMessage());
            }
        }
    }

    public static void updateTravelVolumeTypes(Set<Id> accountIds) {
        Map<String, DK_Volume__c> latestByMatchType = new Map<String, DK_Volume__c>();
        List<DK_Volume__c> dkList = [
            SELECT MatchID__c, Type__c
            FROM DK_Volume__c
            WHERE Account__c IN :accountIds AND MatchID__c != null AND Type__c != null
            ORDER BY CreatedDate DESC
        ];

        for (DK_Volume__c dkv : dkList) {
            String key = dkv.MatchID__c + '_' + dkv.Type__c;
            if (!latestByMatchType.containsKey(key)) {
                latestByMatchType.put(key, dkv);
            }
        }

        Set<String> matchTypeKeys = latestByMatchType.keySet();
        Set<String> matchIds = new Set<String>();
        for (String key : matchTypeKeys) {
            matchIds.add(key.split('_')[0]);
        }

        List<Travel_Volume__c> toUpdate = new List<Travel_Volume__c>();
        for (Travel_Volume__c tv : [
            SELECT Id, MatchID__c, Type__c
            FROM Travel_Volume__c
            WHERE MatchID__c IN :matchIds
        ]) {
            String key = tv.MatchID__c + '_' + tv.Type__c;
            if (latestByMatchType.containsKey(key)) {
                tv.Type__c = latestByMatchType.get(key).Type__c;
            }
            toUpdate.add(tv);
        }

        if (!toUpdate.isEmpty()) {
            try {
                update toUpdate;
            } catch (Exception e) {
                System.debug('Error updating Travel Volume types: ' + e.getMessage());
            }
        }
    }

    public static void updateTravelVolumeMapping(List<DK_Volume__c> newRecords) {
        Set<String> matchTypeKeys = new Set<String>();
        Set<String> matchIds = new Set<String>();
        Set<String> types = new Set<String>();

        for (DK_Volume__c dkv : newRecords) {
            if (dkv.MatchID__c != null && dkv.Type__c != null) {
                matchTypeKeys.add(dkv.MatchID__c + '_' + dkv.Type__c);
                matchIds.add(dkv.MatchID__c);
                types.add(dkv.Type__c);
            }
        }

        if (matchTypeKeys.isEmpty()) return;

        Map<String, Id> matchTypeToTV = new Map<String, Id>();
        for (Travel_Volume__c tv : [
            SELECT Id, MatchID__c, Type__c
            FROM Travel_Volume__c
            WHERE MatchID__c IN :matchIds AND Type__c IN :types
        ]) {
            String key = tv.MatchID__c + '_' + tv.Type__c;
            matchTypeToTV.put(key, tv.Id);
        }

        for (DK_Volume__c dkv : newRecords) {
            String key = dkv.MatchID__c + '_' + dkv.Type__c;
            if (matchTypeToTV.containsKey(key)) {
                dkv.Travel_Volume__c = matchTypeToTV.get(key);
            }
        }
    }
}