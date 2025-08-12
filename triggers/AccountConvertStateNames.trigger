trigger AccountConvertStateNames on Account (before insert, before update, after insert, after update) {
    if (!AccountTriggerHandler.bypassTrigger && Trigger.isBefore) {
        AccountTriggerHandler.handleSalesRegionUpdates(Trigger.new, Trigger.oldMap);
    }
    
    for( Account a : Trigger.new ) {
        if (!String.isBlank(a.BillingState)) {
            if (a.BillingState.equalsIgnoreCase('Alabama')) a.BillingState = 'AL';
            else if (a.BillingState.equalsIgnoreCase('Alaska')) a.BillingState =  'AK' ;
            else if (a.BillingState.equalsIgnoreCase('Arizona')) a.BillingState =  'AZ' ;
            else if (a.BillingState.equalsIgnoreCase('Arkansas')) a.BillingState =  'AR' ;
            else if (a.BillingState.equalsIgnoreCase('California')) a.BillingState = 'CA' ;
            else if (a.BillingState.equalsIgnoreCase('Colorado')) a.BillingState = 'CO' ;
            else if (a.BillingState.equalsIgnoreCase('Connecticut')) a.BillingState = 'CT' ;
            else if (a.BillingState.equalsIgnoreCase('Delaware')) a.BillingState = 'DE' ;
            else if (a.BillingState.equalsIgnoreCase('Florida')) a.BillingState = 'FL' ;
            else if (a.BillingState.equalsIgnoreCase('Georgia')) a.BillingState = 'GA' ;
            else if (a.BillingState.equalsIgnoreCase('Hawaii')) a.BillingState = 'HI' ;
            else if (a.BillingState.equalsIgnoreCase('Idaho')) a.BillingState = 'ID' ;
            else if (a.BillingState.equalsIgnoreCase('Illinois')) a.BillingState = 'IL' ;
            else if (a.BillingState.equalsIgnoreCase('Indiana')) a.BillingState = 'IN' ;
            else if (a.BillingState.equalsIgnoreCase('Iowa')) a.BillingState = 'IA' ;
            else if (a.BillingState.equalsIgnoreCase('Kansas')) a.BillingState = 'KS'; 
            else if (a.BillingState.equalsIgnoreCase('Kentucky')) a.BillingState = 'KY'; 
            else if (a.BillingState.equalsIgnoreCase('Louisiana')) a.BillingState = 'LA'; 
            else if (a.BillingState.equalsIgnoreCase('Maine')) a.BillingState = 'ME' ;
            else if (a.BillingState.equalsIgnoreCase('Maryland')) a.BillingState = 'MD'; 
            else if (a.BillingState.equalsIgnoreCase('Massachusetts')) a.BillingState = 'MA' ;
            else if (a.BillingState.equalsIgnoreCase('Michigan')) a.BillingState = 'MI' ;
            else if (a.BillingState.equalsIgnoreCase('Minnesota')) a.BillingState = 'MN' ;
            else if (a.BillingState.equalsIgnoreCase('Mississippi')) a.BillingState = 'MS' ;
            else if (a.BillingState.equalsIgnoreCase('Missouri')) a.BillingState = 'MO' ;
            else if (a.BillingState.equalsIgnoreCase('Montana')) a.BillingState = 'MT' ;
            else if (a.BillingState.equalsIgnoreCase('Nebraska')) a.BillingState = 'NE' ;
            else if (a.BillingState.equalsIgnoreCase('Nevada')) a.BillingState = 'NV' ;
            else if (a.BillingState.equalsIgnoreCase('New Hampshire')) a.BillingState = 'NH' ;
            else if (a.BillingState.equalsIgnoreCase('New Jersey')) a.BillingState = 'NJ' ;
            else if (a.BillingState.equalsIgnoreCase('New Mexico')) a.BillingState = 'NM' ;
            else if (a.BillingState.equalsIgnoreCase('New York')) a.BillingState = 'NY' ;
            else if (a.BillingState.equalsIgnoreCase('North Carolina')) a.BillingState = 'NC' ;
            else if (a.BillingState.equalsIgnoreCase('North Dakota')) a.BillingState = 'ND' ;
            else if (a.BillingState.equalsIgnoreCase('Ohio')) a.BillingState = 'OH' ;
            else if (a.BillingState.equalsIgnoreCase('Oklahoma')) a.BillingState = 'OK' ;
            else if (a.BillingState.equalsIgnoreCase('Oregon')) a.BillingState = 'OR' ;
            else if (a.BillingState.equalsIgnoreCase('Pennsylvania')) a.BillingState = 'PA' ;
            else if (a.BillingState.equalsIgnoreCase('Rhode Island')) a.BillingState = 'RI' ;
            else if (a.BillingState.equalsIgnoreCase('South Carolina')) a.BillingState = 'SC' ;
            else if (a.BillingState.equalsIgnoreCase('South Dakota')) a.BillingState = 'SD' ;
            else if (a.BillingState.equalsIgnoreCase('Tennessee')) a.BillingState = 'TN' ;
            else if (a.BillingState.equalsIgnoreCase('Texas')) a.BillingState = 'TX' ;
            else if (a.BillingState.equalsIgnoreCase('Utah')) a.BillingState = 'UT' ;
            else if (a.BillingState.equalsIgnoreCase('Vermont')) a.BillingState = 'VT' ;
            else if (a.BillingState.equalsIgnoreCase('Virginia')) a.BillingState = 'VA' ;
            else if (a.BillingState.equalsIgnoreCase('Washington')) a.BillingState = 'WA' ;
            else if (a.BillingState.equalsIgnoreCase('West Virginia')) a.BillingState = 'WV' ;
            else if (a.BillingState.equalsIgnoreCase('Wisconsin')) a.BillingState = 'WI' ;
            else if (a.BillingState.equalsIgnoreCase('Wyoming')) a.BillingState = 'WY' ;
            else if (a.BillingState.equalsIgnoreCase('Ontario')) a.BillingState = 'ON' ;
            else if (a.BillingState.equalsIgnoreCase('Quebec')) a.BillingState = 'QC' ;
            else if (a.BillingState.equalsIgnoreCase('QuéBec')) a.BillingState = 'QC' ;
            else if (a.BillingState.equalsIgnoreCase('British Columbia')) a.BillingState = 'BC' ;
            else if (a.BillingState.equalsIgnoreCase('Alberta')) a.BillingState = 'AB' ;
            else if (a.BillingState.equalsIgnoreCase('Manitoba')) a.BillingState = 'MB' ;
            else if (a.BillingState.equalsIgnoreCase('Saskatchewan')) a.BillingState = 'SK' ;
            else if (a.BillingState.equalsIgnoreCase('Nova Scotia')) a.BillingState = 'NS' ;
            else if (a.BillingState.equalsIgnoreCase('New Brunswick')) a.BillingState = 'NB' ;
            else if (a.BillingState.equalsIgnoreCase('Newfoundland And Labrador')) a.BillingState = 'NL' ;
            else if (a.BillingState.equalsIgnoreCase('Prince Edward Island')) a.BillingState = 'PE' ;
            else if (a.BillingState.equalsIgnoreCase('Northwest Territories')) a.BillingState = 'NT' ;
            else if (a.BillingState.equalsIgnoreCase('Yukon')) a.BillingState = 'YT' ;
            else if (a.BillingState.equalsIgnoreCase('Nunavut')) a.BillingState = 'NU' ;
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.handleAfterInsert(Trigger.new);
        }
        if (Trigger.isInsert || Trigger.isUpdate) {
            //AccountTerritoryNotificationHandler.processAccountTerritoryAssignments(Trigger.new, Trigger.oldMap);
        }
    } else {
        if (Trigger.isUpdate) {
            AccountTriggerHandler.restoreOwnerForClosedOpportunities(Trigger.new, Trigger.oldMap);
        }
    }
}