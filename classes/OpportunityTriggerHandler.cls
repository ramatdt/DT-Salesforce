public with sharing class OpportunityTriggerHandler {
    public static void calculateAmount(List<Opportunity> oppList) {
        Set<Id> oppIds = new Set<Id>();
        Set<Id> recordTypeIds = new Set<Id>();

        // Collect Opportunity Ids and RecordTypeIds
        for (Opportunity opp : oppList) {
            if (opp.Id != null) {
                oppIds.add(opp.Id);
            }
            if (opp.RecordTypeId != null) {
                recordTypeIds.add(opp.RecordTypeId);
            }
        }

        // Query RecordType.DeveloperName for existing Opportunities (on update)
        Map<Id, String> oppIdToRecordType = new Map<Id, String>();
        if (!oppIds.isEmpty()) {
            for (Opportunity opp : [
                SELECT Id, RecordType.DeveloperName
                FROM Opportunity
                WHERE Id IN :oppIds
            ]) {
                oppIdToRecordType.put(opp.Id, opp.RecordType.DeveloperName);
            }
        }

        // Query RecordTypeId to DeveloperName mapping for insert/new records
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        if (!recordTypeIds.isEmpty()) {
            for (RecordType rt : [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE Id IN :recordTypeIds AND SObjectType = 'Opportunity'
            ]) {
                recordTypeMap.put(rt.Id, rt.DeveloperName);
            }
        }

        for (Opportunity opp : oppList) {
            String oppType = opp.Type;
            String recordTypeDevName = '';

            if (opp.Id != null && oppIdToRecordType.containsKey(opp.Id)) {
                recordTypeDevName = oppIdToRecordType.get(opp.Id);
            } else if (opp.RecordTypeId != null && recordTypeMap.containsKey(opp.RecordTypeId)) {
                recordTypeDevName = recordTypeMap.get(opp.RecordTypeId);
            }

            Decimal usAir = opp.U_S_Air_Volume__c != null ? opp.U_S_Air_Volume__c : 0;
            Decimal caAir = opp.Canadian_Air_Volume__c != null ? opp.Canadian_Air_Volume__c : 0;
            Decimal upsell = opp.Value_of_Up_Sell__c != null ? opp.Value_of_Up_Sell__c : 0;
            Decimal estimatedProfit = opp.Estimated_Profit_Amount__c != null ? opp.Estimated_Profit_Amount__c : 0;
            Decimal atpAmount = opp.ATPI_Air_Volume__c != null ? opp.ATPI_Air_Volume__c : 0;
            Decimal nonAtpAmount = opp.Non_ATPI_Agency_Air_Volume__c != null ? opp.Non_ATPI_Agency_Air_Volume__c : 0;

            Decimal calculatedAmount = 0;
            Decimal grandTotalAmount = 0;

            if (oppType == 'New Business' || oppType == 'Global' || oppType == 'Global Rebid or Renewal' || oppType == 'Global Expansion') {
                calculatedAmount = usAir + caAir;
                if (recordTypeDevName == 'Avenir_Global_Business' || recordTypeDevName == 'New_Business_Global') {
                    grandTotalAmount = calculatedAmount + atpAmount + nonAtpAmount;
                }
            } else if (oppType == 'Up-Sell' || oppType == 'Re-Bid' || oppType == 'Renewal / Re-Negotiation') {
                calculatedAmount = upsell;
            } else if (oppType == 'Meeting') {
                if (recordTypeDevName == 'Sales_New_Business') {
                    calculatedAmount = usAir + caAir;
                } else if (recordTypeDevName == 'Sales_Meetings'){
                    calculatedAmount = estimatedProfit;                
                }
            } else {
                calculatedAmount = 0;
            }

            calculatedAmount = calculatedAmount.setScale(0);
            grandTotalAmount = grandTotalAmount.setScale(0);

            opp.Calculated_Amount__c = calculatedAmount;
            opp.Amount = calculatedAmount;
            opp.Grand_Total_of_Global_Opportunity__c = grandTotalAmount;
        }
    }
}