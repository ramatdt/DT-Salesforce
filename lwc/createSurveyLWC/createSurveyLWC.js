import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import createSurvey from "@salesforce/apex/CreateSurveyLWC_Controller.createSurvey";
import communityId from '@salesforce/community/Id';

const ERROR_MESSAGE =   "Your survey could not be loaded. " + 
                        "Please try again by clicking on the " + 
                        "link in your itinerary. If you continue " + 
                        "to experience issues please contact " + 
                        "the customer support phone number " +
                        "designated on your itinerary.";

const ERROR_MESSAGE_FRENCH =    "Votre enquête n’a pas pu être chargée. " + 
                                "Veuillez réessayer en cliquant sur le lien " +
                                "dans votre itinéraire. Si vous rencontrez " +
                                "toujours des problèmes, veuillez composer le " +
                                "numéro de téléphone de l’assistance à la " +
                                "clientèle figurant sur votre itinéraire.";                   

export default class CreateSurveyLWC extends NavigationMixin(LightningElement) {

    accountId = null;
    community = communityId;
    surveyName = null;
    language = null;
    pageName = null;
    renderSpinner = false;
    renderError = false;
    errorMessage = "";

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        const timeoutID = setTimeout(() => {
            this.renderSpinner = true;
        }, 1000);
        if (currentPageReference.state?.SFID && currentPageReference.state?.survey) {
            this.accountId = currentPageReference.state?.SFID;
            this.surveyName = currentPageReference.state?.survey;
            this.language = this.getLanguage();
            createSurvey({
                accountId: this.accountId, surveyName: this.surveyName, communityId: this.community, language: this.language
            })
            .then((result) => {
                window.open(result, "_self");
            })
            .catch((error) => {
                clearTimeout(timeoutID);
                this.renderSpinner = false;
                this.errorMessage = this.language == 'en' ? ERROR_MESSAGE : ERROR_MESSAGE_FRENCH;
                console.error(error.body);
                this.renderError = true;
            });
        } else {
            clearTimeout(timeoutID);
            this.renderSpinner = false;
            this.errorMessage = currentPageReference.attributes.name == "ClientSurveyENG__c" ? ERROR_MESSAGE : ERROR_MESSAGE_FRENCH;
            this.renderError = true;
        }
    }

    getLanguage(){
        console.log("LANGUAGE");
        console.log(window.location.pathname);
        console.log(window.location.pathname);
        if(window.location.pathname.includes("ENGSurvey")){
            return "en";
        } else if (window.location.pathname.includes("EnqueteFRCA")){
            return "fr";
        }
    }
}