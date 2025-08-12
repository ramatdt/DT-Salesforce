import { LightningElement, api, wire } from 'lwc';
import getTravelVolumeSummary from '@salesforce/apex/TravelVolumeController.getTravelVolumeSummary';

export default class clientVolumeSummary extends LightningElement {
    @api recordId;

    selectedYear = 'current';
    yearOptions = [
        { label: 'Current Year', value: 'current' },
        { label: 'Previous Year', value: 'previous' }
    ];

    currentYear = new Date().getFullYear();
    previousYear = this.currentYear - 1;

    summaryData;
    currentCoreFields = [];
    currentAvenirFields = [];
    previousCoreFields = [];
    previousAvenirFields = [];

    isLoading = true;
    error;

    @wire(getTravelVolumeSummary, { accountId: '$recordId' })
    wiredSummary({ error, data }) {
        this.isLoading = false;

        if (data) {
            this.summaryData = data;
            this.currentCoreFields = this.buildFieldArray(data.currentYearCore);
            this.currentAvenirFields = this.buildFieldArray(data.currentYearAvenir);
            this.previousCoreFields = this.buildFieldArray(data.previousYearCore);
            this.previousAvenirFields = this.buildFieldArray(data.previousYearAvenir);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.summaryData = undefined;
            this.currentCoreFields = [];
            this.currentAvenirFields = [];
            this.previousCoreFields = [];
            this.previousAvenirFields = [];
            console.error('Error loading travel volume summary', error);
        }
    }

    handleYearChange(event) {
        this.selectedYear = event.detail.value;
    }

    buildFieldArray(data) {
        if (!data) return [];
        const currency = data.currencyIsoCode;

        return [
            // Row 1
            { label: 'Air/Rail Spend Domestic', value: data.airSpendDomestic, currencyCode: currency },
            { label: 'Car Days', value: data.carDays },
            
            // Row 2
            { label: 'Air/Rail Spend Transborder', value: data.airSpendTransborder, currencyCode: currency },
            { label: 'Car Spend', value: data.carSpend, currencyCode: currency },
            
            // Row 3
            { label: 'Air/Rail Spend International', value: data.airSpendInternational, currencyCode: currency },
            { label: 'Hotel Nights', value: data.hotelNights },
            
            // Row 4
            { label: 'Air/Rail Spend Total', value: data.airSpendTotal, currencyCode: currency },
            { label: 'Hotel Spend', value: data.hotelSpend, currencyCode: currency },
            
            // Row 5
            { label: 'Air/Rail Transactions', value: data.airTransactions },
            { label: '', value: '' }, // Empty spacer
            
            // Row 6
            { label: 'Total Trips', value: data.totalTrips },
            { label: '', value: '' }  // Empty spacer
        ];
    }

    /*
    buildFieldArray(data) {
        if (!data) return [];
        const currency = data.currencyIsoCode;

        return [
            { label: 'Air Spend Domestic', value: data.airSpendDomestic, currencyCode: currency },
            { label: 'Car Days', value: data.carDays },
            { label: 'Air Spend Transborder', value: data.airSpendTransborder, currencyCode: currency },
            { label: 'Car Spend', value: data.carSpend, currencyCode: currency },
            { label: 'Air Spend International', value: data.airSpendInternational, currencyCode: currency },
            { label: 'Hotel Nights', value: data.hotelNights },
            { label: 'Air Spend Total', value: data.airSpendTotal, currencyCode: currency },            
            { label: 'Hotel Spend', value: data.hotelSpend, currencyCode: currency },
            { label: 'Air Transactions', value: data.airTransactions },
                // Insert a spacer
            { label: '' },
            { label: 'Total Trips', value: data.totalTrips }
        ];
    }
    */

    get isComboboxDisabled() {
        return this.isLoading || this.error;
    }

    get showCurrentYear() {
        return this.selectedYear === 'current' && this.summaryData;
    }

    get showPreviousYear() {
        return this.selectedYear === 'previous' && this.summaryData;
    }

    get currentCoreLabel() {
        return `Core: ${this.currentYear}`;
    }

    get currentAvenirLabel() {
        return `Avenir: ${this.currentYear}`;
    }

    get previousCoreLabel() {
        return `Core: ${this.previousYear}`;
    }

    get previousAvenirLabel() {
        return `Avenir: ${this.previousYear}`;
    }
}