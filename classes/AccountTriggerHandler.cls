public with sharing class AccountTriggerHandler {    
    public static Boolean bypassTrigger = false;

    public static final Decimal ENTERPRISE_REVENUE_THRESHOLD = 1600000000;
    public static Map<String, String> enterpriseStateToRegionMap = new Map<String, String>();
    public static Map<String, String> midMarketStateToRegionMap = new Map<String, String>();
    public static Map<String, String> accountNameToRegionMap = new Map<String, String>();

    // Static initializer to load metadata information
    static {
        try {
            // Fetch metadata for territory-region mapping
            for (Territory_Region_Mapping__mdt region : [
                SELECT Region__c, States__c, IsEnterprise__c 
                FROM Territory_Region_Mapping__mdt
            ]) {
                Map<String, String> targetMap = region.IsEnterprise__c ? 
                    enterpriseStateToRegionMap : 
                    midMarketStateToRegionMap;

                for (String state : region.States__c.split(',')) {
                    String mapState = state.trim().toUpperCase();
                    
                    // For standard region mapping
                    targetMap.put(mapState, region.Region__c);
                    
                    // For account name to region mapping (Strategic Accounts)
                    accountNameToRegionMap.put(mapState, region.Region__c);
                }
            }
        } catch (Exception e) {
            System.debug('Error while fetching metadata: ' + e.getMessage());
        }
    }

    /**
    * Handles sales region updates when Accounts are inserted or updated.
    * Ensures updates only when necessary based on field changes.
    */
    public static void handleSalesRegionUpdates(List<Account> newAccounts, Map<Id, Account> oldMap) {
        for (Account acc : newAccounts) {
            if (shouldProcess(acc, oldMap?.get(acc.Id))) {
                updateAccountFields(acc);
            }
        }
    }

    public static void applyRegionMapping(List<Account> accounts) {
        for (Account acc : accounts) {
            updateAccountFields(acc);
        }
    }

    private static Boolean shouldProcess(Account newAcc, Account oldAcc) {
        // Existing field change checks
        Boolean fieldsChanged = oldAcc == null ||
            newAcc.Name != oldAcc.Name ||
            newAcc.BillingCountry != oldAcc.BillingCountry ||
            newAcc.BillingState != oldAcc.BillingState ||
            newAcc.BillingCity != oldAcc.BillingCity ||
            newAcc.AnnualRevenue != oldAcc.AnnualRevenue;

        // Check if the Update Sales Region checkbox is triggered
        Boolean checkboxTriggered = (oldAcc == null && newAcc.Update_Sales_Region__c) || 
                                    (oldAcc != null && newAcc.Update_Sales_Region__c && !oldAcc.Update_Sales_Region__c);

        return fieldsChanged || checkboxTriggered;
    }

    private static void updateAccountFields(Account acc) {
        String accountName = acc.Name?.trim().toUpperCase();
        acc.Sales_Region__c = null;

        if (accountNameToRegionMap.containsKey(accountName)) {
            acc.Sales_Region__c = accountNameToRegionMap.get(accountName);
            return;
        }

        if (String.isBlank(acc.BillingCountry)) {
            System.debug('Skipping update: BillingCountry is null');
            return;
        }

        if (acc.BillingCountry.equalsIgnoreCase('Canada') || acc.BillingCountry.equalsIgnoreCase('CAN')) {
            handleCanada(acc);
        } else if (acc.BillingCountry.equalsIgnoreCase('US') || acc.BillingCountry.equalsIgnoreCase('USA') || acc.BillingCountry.equalsIgnoreCase('United States') ||
                   acc.BillingCountry.equalsIgnoreCase('United States of America')) {
            handleUS(acc);
        }
    }

    private static void handleCanada(Account acc) {
        acc.Sales_Region__c = 'Canada';
    }

    private static Boolean isEnterpriseAccount(Account acc) {
        return acc.AnnualRevenue != null && 
               acc.AnnualRevenue >= ENTERPRISE_REVENUE_THRESHOLD;
    }

    private static void handleUS(Account acc) {
        if (isEnterpriseAccount(acc)) {
            handleEnterprise(acc);
        } else {
            handleMidMarket(acc);
        }
    }

    private static void handleEnterprise(Account acc) {
        acc.Sales_Region__c = 'Enterprise';
        acc.Enterprise_State__c = getEnterpriseRegion(acc.BillingState);
    }

    private static void handleMidMarket(Account acc) {
        String baseRegion = getMidMarketRegion(acc.BillingState);
        acc.Sales_Region__c = baseRegion;
    }

    private static String getEnterpriseRegion(String state) {
        return getRegion(state, enterpriseStateToRegionMap);
    }

    private static String getMidMarketRegion(String state) {
        return getRegion(state, midMarketStateToRegionMap);
    }

    private static String getRegion(String state, Map<String, String> regionMap) {
        if (String.isBlank(state)) return null;
        String key = state.trim().toUpperCase();
        return regionMap.get(key);
    }

    public static void handleAfterInsert(List<Account> newAccounts) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : newAccounts) {
            if (String.isBlank(acc.Type) && acc.Is_Converted_from_Lead__c == TRUE) {
                Account updatedAcc = new Account(
                    Id = acc.Id,
                    Type = 'Prospect Account'
                );
                accountsToUpdate.add(updatedAcc);
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public static void restoreOwnerForClosedOpportunities(List<Account> newAccounts, Map<Id, Account> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : newAccounts) {
            if (acc.OwnerId != oldMap.get(acc.Id).OwnerId) {
                accountIds.add(acc.Id);
            }
        }
        if (accountIds.isEmpty()) {
            return;
        }
        Map<Id, Opportunity> closedOpportunitiesMap = new Map<Id, Opportunity>([SELECT Id, OwnerId FROM Opportunity WHERE IsClosed = TRUE AND AccountId IN :accountIds AND OwnerId != NULL]);
        if (!closedOpportunitiesMap.isEmpty()) {
            restoreOwnerForClosedOpportunitiesFuture(JSON.serialize(closedOpportunitiesMap));
        }
    }

    @future
    public static void restoreOwnerForClosedOpportunitiesFuture(String mapString) {
        Map<Id, Opportunity> closedOpportunitiesMap = (Map<Id, Opportunity>) JSON.deserialize(mapString, Map<Id, Opportunity>.class);
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opp : [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :closedOpportunitiesMap.keySet()]) {
            if (opp.OwnerId != closedOpportunitiesMap.get(opp.Id).OwnerId) {
                opp.OwnerId = closedOpportunitiesMap.get(opp.Id).OwnerId;
                opportunitiesToUpdate.add(opp);
            }
        }
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
}