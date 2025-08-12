public with sharing class LeadHandler {
    private static Boolean isExecuting = false;
    private static final Decimal ENTERPRISE_REVENUE_THRESHOLD = 1600000000;
    private static Map<String, String> enterpriseStateToRegionMap = new Map<String, String>();
    private static Map<String, String> midMarketStateToRegionMap = new Map<String, String>();
    public static Map<String, String> companyNameToRegionMap = new Map<String, String>();

    static {
        try {
            for (Territory_Region_Mapping__mdt region : [
                SELECT Region__c, States__c, IsEnterprise__c 
                FROM Territory_Region_Mapping__mdt
            ]) {
                Map<String, String> targetMap = region.IsEnterprise__c ? 
                    enterpriseStateToRegionMap : 
                    midMarketStateToRegionMap;

                // Process states for both region mapping and account name check
                for (String state : region.States__c.split(',')) {
                    String mapState = state.trim().toUpperCase();
                    
                    // For standard region mapping
                    targetMap.put(mapState, region.Region__c);
                    
                    // For account name to region mapping (Strategic Account)
                    companyNameToRegionMap.put(mapState, region.Region__c);
                }
            }
        } catch (Exception e) {
            System.debug('Error initializing region mappings: ' + e.getMessage());
        }
    }

    /**
    * Handles assignment of sales regions based on Lead attributes.
    * @param newLeads The list of new or updated leads
    * @param oldMap The map of old lead values (before update)
    */
    public static void handleSalesRegion(List<Lead> newLeads, Map<Id, Lead> oldMap) {
        if (isExecuting) return;
        isExecuting = true;

        try {
            List<Lead> leadsToUpdate = new List<Lead>();

            for (Lead lea : newLeads) {
                if (shouldProcess(lea, oldMap?.get(lea.Id))) {
                    updateLeadFields(lea);
                    leadsToUpdate.add(lea);
                }
            }

            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate; 
            }
        } catch (Exception e) {
            System.debug('Error in handleSalesRegion: ' + e.getMessage());
        } finally {
            isExecuting = false;
        }
    }

    public static void applyRegionMapping(List<Lead> leads) {
        for (Lead lea : leads) {
            updateLeadFields(lea);
        }
    }

    private static Boolean shouldProcess(Lead newLead, Lead oldLead) {
        // Existing field change checks
        Boolean fieldsChanged = oldLead == null ||
            newLead.Company != oldLead.Company ||
            newLead.Country != oldLead.Country ||
            newLead.State != oldLead.State ||
            newLead.City != oldLead.City ||
            newLead.AnnualRevenue != oldLead.AnnualRevenue;

        // Check if the Update Sales Region checkbox is triggered
        Boolean checkboxTriggered = (oldLead == null && newLead.Update_Sales_Region__c) || 
                                    (oldLead != null && newLead.Update_Sales_Region__c && !oldLead.Update_Sales_Region__c);

        return fieldsChanged || checkboxTriggered;
    }

    private static void updateLeadFields(Lead lead) {
        String company = lead.Company?.trim().toUpperCase();
        lead.Sales_Region__c = null;

        if (companyNameToRegionMap.containsKey(company)) {
            lead.Sales_Region__c = companyNameToRegionMap.get(company);
            return; 
        }        

        if (String.isBlank(lead.Country)) {
            System.debug('Skipping update: Country is null');
            return;
        }

        if (lead.Country.equalsIgnoreCase('Canada') || lead.Country.equalsIgnoreCase('CAN')) {
            handleCanada(lead);
        } else if (lead.Country.equalsIgnoreCase('US') || lead.Country.equalsIgnoreCase('USA') || lead.Country.equalsIgnoreCase('United States') ||
                   lead.Country.equalsIgnoreCase('United States of America')) {
            handleUS(lead);
        }
    }

    private static void handleCanada(Lead lea) {
        lea.Sales_Region__c = 'Canada';
    }

    private static void handleUS(Lead lea) {
        if (isEnterprise(lea)) {
            handleEnterprise(lea);
        } else {
            handleMidMarket(lea);
        }
    }

    private static Boolean isEnterprise(Lead lea) {
        return lea.AnnualRevenue != null && 
               lea.AnnualRevenue >= ENTERPRISE_REVENUE_THRESHOLD;
    }

    private static void handleEnterprise(Lead lea) {
        lea.Sales_Region__c = 'Enterprise';
    }

    private static void handleMidMarket(Lead lea) {
       String baseRegion = getMidMarketRegion(lea.State);
        lea.Sales_Region__c = baseRegion;
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
}