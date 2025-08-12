trigger LeadConvertStateNames on Lead (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        LeadHandler.handleSalesRegion(Trigger.new, Trigger.oldMap);
    }
    
    for( Lead l : Trigger.new ) {
        if (!String.isBlank(l.State)) {
            if (l.State.equalsIgnoreCase('Alabama')) l.State = 'AL';
            else if (l.State.equalsIgnoreCase('Alaska')) l.State =  'AK' ;
            else if (l.State.equalsIgnoreCase('Arizona')) l.State =  'AZ' ;
            else if (l.State.equalsIgnoreCase('Arkansas')) l.State =  'AR' ;
            else if (l.State.equalsIgnoreCase('California')) l.State = 'CA' ;
            else if (l.State.equalsIgnoreCase('Colorado')) l.State = 'CO' ;
            else if (l.State.equalsIgnoreCase('Connecticut')) l.State = 'CT' ;
            else if (l.State.equalsIgnoreCase('Delaware')) l.State = 'DE' ;
            else if (l.State.equalsIgnoreCase('Florida')) l.State = 'FL' ;
            else if (l.State.equalsIgnoreCase('Georgia')) l.State = 'GA' ;
            else if (l.State.equalsIgnoreCase('Hawaii')) l.State = 'HI' ;
            else if (l.State.equalsIgnoreCase('Idaho')) l.State = 'ID' ;
            else if (l.State.equalsIgnoreCase('Illinois')) l.State = 'IL' ;
            else if (l.State.equalsIgnoreCase('Indiana')) l.State = 'IN' ;
            else if (l.State.equalsIgnoreCase('Iowa')) l.State = 'IA' ;
            else if (l.State.equalsIgnoreCase('Kansas')) l.State = 'KS'; 
            else if (l.State.equalsIgnoreCase('Kentucky')) l.State = 'KY'; 
            else if (l.State.equalsIgnoreCase('Louisiana')) l.State = 'LA'; 
            else if (l.State.equalsIgnoreCase('Maine')) l.State = 'ME' ;
            else if (l.State.equalsIgnoreCase('Maryland')) l.State = 'MD'; 
            else if (l.State.equalsIgnoreCase('Massachusetts')) l.State = 'MA' ;
            else if (l.State.equalsIgnoreCase('Michigan')) l.State = 'MI' ;
            else if (l.State.equalsIgnoreCase('Minnesota')) l.State = 'MN' ;
            else if (l.State.equalsIgnoreCase('Mississippi')) l.State = 'MS' ;
            else if (l.State.equalsIgnoreCase('Missouri')) l.State = 'MO' ;
            else if (l.State.equalsIgnoreCase('Montana')) l.State = 'MT' ;
            else if (l.State.equalsIgnoreCase('Nebraska')) l.State = 'NE' ;
            else if (l.State.equalsIgnoreCase('Nevada')) l.State = 'NV' ;
            else if (l.State.equalsIgnoreCase('New Hampshire')) l.State = 'NH' ;
            else if (l.State.equalsIgnoreCase('New Jersey')) l.State = 'NJ' ;
            else if (l.State.equalsIgnoreCase('New Mexico')) l.State = 'NM' ;
            else if (l.State.equalsIgnoreCase('New York')) l.State = 'NY' ;
            else if (l.State.equalsIgnoreCase('North Carolina')) l.State = 'NC' ;
            else if (l.State.equalsIgnoreCase('North Dakota')) l.State = 'ND' ;
            else if (l.State.equalsIgnoreCase('Ohio')) l.State = 'OH' ;
            else if (l.State.equalsIgnoreCase('Oklahoma')) l.State = 'OK' ;
            else if (l.State.equalsIgnoreCase('Oregon')) l.State = 'OR' ;
            else if (l.State.equalsIgnoreCase('Pennsylvania')) l.State = 'PA' ;
            else if (l.State.equalsIgnoreCase('Rhode Island')) l.State = 'RI' ;
            else if (l.State.equalsIgnoreCase('South Carolina')) l.State = 'SC' ;
            else if (l.State.equalsIgnoreCase('South Dakota')) l.State = 'SD' ;
            else if (l.State.equalsIgnoreCase('Tennessee')) l.State = 'TN' ;
            else if (l.State.equalsIgnoreCase('Texas')) l.State = 'TX' ;
            else if (l.State.equalsIgnoreCase('Utah')) l.State = 'UT' ;
            else if (l.State.equalsIgnoreCase('Vermont')) l.State = 'VT' ;
            else if (l.State.equalsIgnoreCase('Virginia')) l.State = 'VA' ;
            else if (l.State.equalsIgnoreCase('Washington')) l.State = 'WA' ;
            else if (l.State.equalsIgnoreCase('West Virginia')) l.State = 'WV' ;
            else if (l.State.equalsIgnoreCase('Wisconsin')) l.State = 'WI' ;
            else if (l.State.equalsIgnoreCase('Wyoming')) l.State = 'WY' ;
            else if (l.State.equalsIgnoreCase('Ontario')) l.State = 'ON' ;
            else if (l.State.equalsIgnoreCase('Quebec')) l.State = 'QC' ;
            else if (l.State.equalsIgnoreCase('QuéBec')) l.State = 'QC' ;
            else if (l.State.equalsIgnoreCase('British Columbia')) l.State = 'BC' ;
            else if (l.State.equalsIgnoreCase('Alberta')) l.State = 'AB' ;
            else if (l.State.equalsIgnoreCase('Manitoba')) l.State = 'MB' ;
            else if (l.State.equalsIgnoreCase('Saskatchewan')) l.State = 'SK' ;
            else if (l.State.equalsIgnoreCase('Nova Scotia')) l.State = 'NS' ;
            else if (l.State.equalsIgnoreCase('New Brunswick')) l.State = 'NB' ;
            else if (l.State.equalsIgnoreCase('Newfoundland And Labrador')) l.State = 'NL' ;
            else if (l.State.equalsIgnoreCase('Prince Edward Island')) l.State = 'PE' ;
            else if (l.State.equalsIgnoreCase('Northwest Territories')) l.State = 'NT' ;
            else if (l.State.equalsIgnoreCase('Yukon')) l.State = 'YT' ;
            else if (l.State.equalsIgnoreCase('Nunavut')) l.State = 'NU' ;
    	}
	}
}