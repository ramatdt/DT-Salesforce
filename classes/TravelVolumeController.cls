public with sharing class TravelVolumeController {

    public class TravelVolumeSummary {
        @AuraEnabled public AggregatedData currentYearCore;
        @AuraEnabled public AggregatedData currentYearAvenir;
        @AuraEnabled public AggregatedData previousYearCore;
        @AuraEnabled public AggregatedData previousYearAvenir;
    }

    public class AggregatedData {
        @AuraEnabled public Decimal airSpendTotal = 0;
        @AuraEnabled public Decimal carSpend = 0;
        @AuraEnabled public Decimal hotelSpend = 0;
        @AuraEnabled public Decimal airTransactions = 0;
        @AuraEnabled public Decimal carDays = 0;
        @AuraEnabled public Decimal hotelNights = 0;
        @AuraEnabled public Decimal airSpendDomestic = 0;
        @AuraEnabled public Decimal airSpendInternational = 0;
        @AuraEnabled public Decimal totalTrips = 0;
        @AuraEnabled public Decimal airSpendTransborder = 0;
        @AuraEnabled public String currencyIsoCode;
    }

    @AuraEnabled(cacheable=true)
    public static TravelVolumeSummary getTravelVolumeSummary(String accountId) {
        if (String.isBlank(accountId)) {
            throw new AuraHandledException('Account ID is required');
        }

        TravelVolumeSummary summary = new TravelVolumeSummary();
        String currentYear = String.valueOf(Date.today().year());
        String previousYear = String.valueOf(Date.today().year() - 1);

        List<Travel_Volume__c> volumes = [
            SELECT Type__c, Reported_Year__c, CurrencyIsoCode,
                   Air_Spend_Total__c, Car_Spend__c, Hotel_Spend__c,
                   Air_Transactions__c, Car_Days__c, Hotel_Nights__c, 
                   Air_Spend_Domestic__c, Air_Spend_International__c, Total_Trips__c,
                   Air_Spend_Transborder__c
            FROM Travel_Volume__c 
            WHERE Account__c = :accountId 
            AND Reported_Year__c IN (:currentYear, :previousYear)
            ORDER BY Reported_Year__c DESC
        ];

        summary.currentYearCore = new AggregatedData();
        summary.currentYearAvenir = new AggregatedData();
        summary.previousYearCore = new AggregatedData();
        summary.previousYearAvenir = new AggregatedData();

        for (Travel_Volume__c vol : volumes) {
            AggregatedData target;

            if (vol.Reported_Year__c == currentYear) {
                target = vol.Type__c == 'Core' ? summary.currentYearCore : summary.currentYearAvenir;
            } else if (vol.Reported_Year__c == previousYear) {
                target = vol.Type__c == 'Core' ? summary.previousYearCore : summary.previousYearAvenir;
            }

            if (target != null) {
                target.airSpendTotal += vol.Air_Spend_Total__c != null ? vol.Air_Spend_Total__c : 0;
                target.carSpend += vol.Car_Spend__c != null ? vol.Car_Spend__c : 0;
                target.hotelSpend += vol.Hotel_Spend__c != null ? vol.Hotel_Spend__c : 0;
                target.airTransactions += vol.Air_Transactions__c != null ? vol.Air_Transactions__c : 0;
                target.carDays += vol.Car_Days__c != null ? vol.Car_Days__c : 0;
                target.hotelNights += vol.Hotel_Nights__c != null ? vol.Hotel_Nights__c : 0;
                target.airSpendDomestic += vol.Air_Spend_Domestic__c != null ? vol.Air_Spend_Domestic__c : 0;
                target.airSpendInternational += vol.Air_Spend_International__c != null ? vol.Air_Spend_International__c : 0;
                target.totalTrips += vol.Total_Trips__c != null ? vol.Total_Trips__c : 0;
                target.airSpendTransborder += vol.Air_Spend_Transborder__c != null ? vol.Air_Spend_Transborder__c : 0;

                // Capture currency from first record in group
                if (target.currencyIsoCode == null && vol.CurrencyIsoCode != null) {
                    target.currencyIsoCode = vol.CurrencyIsoCode;
                }
            }
        }

        return summary;
    }
}