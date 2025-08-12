public with sharing class TravelVolumeTriggerHandler {

    // Maps for converting both numeric and full month names to 3-letter format
    private static final Map<String, String> monthToNumericMap = new Map<String, String>{
        'JANUARY' => '01', 'JAN' => '01', '1' => '01', '01' => '01',
        'FEBRUARY' => '02', 'FEB' => '02', '2' => '02', '02' => '02',
        'MARCH' => '03', 'MAR' => '03', '3' => '03', '03' => '03',
        'APRIL' => '04', 'APR' => '04', '4' => '04', '04' => '04',
        'MAY' => '05', '5' => '05', '05' => '05',
        'JUNE' => '06', 'JUN' => '06', '6' => '06', '06' => '06',
        'JULY' => '07', 'JUL' => '07', '7' => '07', '07' => '07',
        'AUGUST' => '08', 'AUG' => '08', '8' => '08', '08' => '08',
        'SEPTEMBER' => '09', 'SEP' => '09', '9' => '09', '09' => '09',
        'OCTOBER' => '10', 'OCT' => '10', '10' => '10',
        'NOVEMBER' => '11', 'NOV' => '11', '11' => '11',
        'DECEMBER' => '12', 'DEC' => '12', '12' => '12'
    };

    public static void normalizeReportedMonth(List<Travel_Volume__c> tvList) {
        for (Travel_Volume__c tv : tvList) {
            if (tv.Reported_Month__c != null) {
                String input = tv.Reported_Month__c.trim().toUpperCase();
                if (monthToNumericMap.containsKey(input)) {
                    tv.Reported_Month__c = monthToNumericMap.get(input);
                }
            }
        }
    }
}