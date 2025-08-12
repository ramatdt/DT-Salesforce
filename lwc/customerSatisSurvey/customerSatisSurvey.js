/**
 * Created by zacox on 3/10/24.
 */

import { LightningElement, wire, track } from "lwc";
import { CurrentPageReference } from 'lightning/navigation';
import SURVEY_HEADER_EN from "@salesforce/contentAssetUrl/GenericHeaderENpng";
import SURVEY_HEADER_FR from "@salesforce/contentAssetUrl/GenericHeaderFRjpg";
import submitResponses from "@salesforce/apex/SurveyController.submitResponses";
import getSurveyInfo from "@salesforce/apex/SurveyController.getSurveyInfo";
import submitNPSResponse from "@salesforce/apex/SurveyController.submitNPSResponse";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FORM_FACTOR from "@salesforce/client/formFactor";

export default class CustomerSatisSurvey extends LightningElement {
    language;
    surveyHeader;
    likelyToRecoText;
    otherCommentsTxt;
    infoText;
    dataProtectionText;
    privacyPolicyLink;
    privacyPolicyLinkText;
    _showOptionalSection = false;
    _showSpinner = true;
    _showThankYou  = false;
    _showNPS = false;
    dataProtectionChecked = false;
    dataProtectionValidity = false;
    surveyResponseId;

    @track responseMap = {};
    @track questionMap = {};

    get titleText() {
        return this.language === "en" ?
          "Direct Travel Customer Satisfaction Survey" :
          "Sondage sur la satisfaction de la clientèle de Direct Travel";
    }
    get notLikelyText() {
        return this.language === "en" ?
          "Not at all Likely" :
          "Pas du tout probable";
    }
    get likelyText() {
        return this.language === "en" ?
          "Extremely Likely" :
          "Extrêmement probable";
    }
    get submitText() {
        return this.language === "en" ?
          "Submit" :
          "Soumettre";
    }
    get namePlaceholder() {
        return this.language === "en" ?
          "Please enter your name" :
          "Entrez votre nom";
    }
    get emailPlaceholder() {
        return this.language === "en" ?
          "Please enter your email address" :
          "Entrez votre adresse e-mail";
    }
    get otherCommentsPlaceholder() {
        return this.language === "en" ?
          "Please enter any other comments here" :
          "Entrez votre résponse";
    }
    get optionalFeedbackHeaderText() {
        return this.language === "en" ?
          "Optional Feedback" :
          "Rétroaction Facultative";
    }
    get optionalSubmitText() {
        return this.language === "en" ?
          "Submit Feedback" :
          "Soumettre des Commentaires";
    }

    get requireDataProtection() {
        if(this.responseMap[this.questionMap.infoEmail] || this.responseMap[this.questionMap.infoName]) {
            console.log('Data protection required');
            return true;
        }
        console.log('Data protection NOT required');
        return false;
    }

    get thankYouText() {
        return this.language === "en" ?
          "Your response has been submitted." :
          "Votre réponse a été envoyée.";
    }

    get thankYouSubText() {
        return this.language === "en" ?
          "Thank you for your feedback and we appreciate your time!" :
          "Nous vous remercions pour votre retour d’information";
    }

    get thankYouSubText2() {
        return this.language === "en" ?
          null :
          "et pour le temps que vous nous avez consacré!";
    }

    get showThankYou() {
        return this._showThankYou && !this._showOptionalSection;
    }

    get showNPS() {
        return !this._showThankYou && !this._showOptionalSection && this._showNPS;
    }

    get showHeader() {
        return this._showNPS || this._showOptionalSection;
    }

    get isMobileFormFactor() {
        return FORM_FACTOR === 'Small'
    }

    get headerClassList() {
        if(FORM_FACTOR !== 'Small') {
            return 'slds-col slds-size_1-of-1 slds-grid_align-center slds-text-align_center slds-m-vertical_xx-large';
        }
        return 'slds-col slds-size_1-of-1 slds-grid_align-center slds-text-align_center slds-m-vertical_large';
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.surveyResponseId = currentPageReference.state?.resp;
            this.language = currentPageReference.state?.lang;
            this.surveyHeader = this.language === "en" ? SURVEY_HEADER_EN : SURVEY_HEADER_FR;
        }
    }

    @wire(getSurveyInfo, { responseId: "$surveyResponseId" })
    wiredSurveyQuestions({ error, data }) {
        if (data) {
            const surveyInfo = JSON.parse(data);
            const surveyQuestions = surveyInfo.questions;
            const surveyResponse = surveyInfo.surveyResponse;
            console.log("surveyQuestions : " + JSON.stringify(surveyQuestions));
            if(surveyResponse.Status__c === 'Completed') {
                this._showThankYou = true;
                this._showOptionalSection = false;
                this._showSpinner = false;
            }else {
                surveyQuestions.forEach((question) => {
                    if (question.Question_Type__c === "NPS") {
                        this.likelyToRecoText = this.language === "en" ? question.Full_Question_Text__c : question.French_Question_Text__c;
                        this.questionMap.recommend = question.Id;
                    } else if (question.Question_Type__c === "FreeText") {
                        this.otherCommentsTxt = this.language === "en" ? question.Full_Question_Text__c : question.French_Question_Text__c;
                        this.questionMap.feedback = question.Id;
                    } else if (question.Question_Type__c === "ShortText") {
                        if(question.Full_Question_Text__c.includes("email") || question.French_Question_Text__c.includes("email")) {
                            this.infoText = this.language === "en" ? question.Full_Question_Text__c : question.French_Question_Text__c;
                            this.questionMap.infoEmail = question.Id;
                        } else if(question.Full_Question_Text__c.includes("name") || question.French_Question_Text__c.includes("nom")) {
                            // this.infoText = this.language === "en" ? question.Full_Question_Text__c : question.French_Question_Text__c;
                            this.questionMap.infoName = question.Id;
                        }
                    } else if (question.Question_Type__c === "RadioButton") {
                        this.dataProtectionText = this.language === "en" ? question.Full_Question_Text__c : question.French_Question_Text__c;
                        this.generateDataProtectionInfo(this.dataProtectionText);
                        this.questionMap.dataProtection = question.Id;
                    }
                    this._showSpinner = false;
                    this._showNPS = true;
                });
            }

            console.log("this.questionMap : " + JSON.stringify(this.questionMap));
        } else if (error) {
            console.error(error);
            this._showSpinner = false;
        }
        this._showSpinner = false;
    }

    generateDataProtectionInfo (dataProtectionText) {
        this.dataProtectionText = dataProtectionText.substring(0, dataProtectionText.indexOf("Privacy | "));
        this.privacyPolicyLinkText = dataProtectionText.substring(dataProtectionText.indexOf("Privacy | "));
        this.privacyPolicyLink = this.language === "en" ? "https://www.dt.com/privacy/" : "https://www.dt.com/fr-ca/politique-de-confidentialite/";
    }

    handleRecommendClick(event) {
        event.preventDefault();
        const clickIndex = event.target.dataset.index;
        if(this.responseMap[this.questionMap.recommend] === clickIndex) {

        }
        this.template.querySelectorAll(".recoBttn").forEach((button) => {
            if (button.dataset.index == clickIndex) {
                if(button.classList.contains("slds-button_neutral")) {
                    button.classList.remove("slds-button_neutral");
                    button.classList.add("slds-button_brand");
                } else {
                    button.classList.remove("slds-button_brand");
                    button.classList.add("slds-button_neutral");
                }
            } else {
                button.classList.remove("slds-button_brand");
                button.classList.add("slds-button_neutral");
            }
        });
        if(this.responseMap[this.questionMap.recommend] === clickIndex) {
            this.responseMap[this.questionMap.recommend] = undefined;
            return;
        }
        this.responseMap[this.questionMap.recommend] = clickIndex;
    }

    handleSubmitClick(event) {
        event.preventDefault();
        if(this.responseMap[this.questionMap.recommend] !== undefined) {
            this._showSpinner = true;
            this.submitNPSResponse();
        }
    }

    handleOptionalSubmitClick(event) {
        event.preventDefault();
        let validEntries = true;
        if(!this.requireDataProtection) {
            // Submit the survey
            let emailBox = this.template.querySelector("lightning-input[data-name='email']");
            let emailValid  = emailBox.checkValidity();
            if(!emailValid) {
                validEntries = false;
                emailBox.reportValidity();
            }
        } else {
            let dataProtectionBox = this.template.querySelector("lightning-input[data-name='data-protection-checkbox']");
            dataProtectionBox.reportValidity();
            if(!this.dataProtectionChecked) {
                validEntries = false;
            }
        }

        if(validEntries) {
            this._showSpinner = true;
            this.submitResponse();
        }
    }

    handleDataProtectionChange(event) {
        this.dataProtectionChecked = event.target.checked;
        this.responseMap[this.questionMap.dataProtection] = event.target.checked;
    }

    handleCommentsChange(event) {
        this.responseMap[this.questionMap.feedback] = event.target.value;

    }

    handleNameChange(event) {
        this.responseMap[this.questionMap.infoName] = event.target.value;
    }

    handleEmailChange(event) {
        this.responseMap[this.questionMap.infoEmail] = event.target.value;
    }

    submitResponse() {
        console.log('Submitting response');
        console.log("this.responseMap : " + JSON.stringify(this.responseMap));
        let responses = [];
        for (let key in this.responseMap) {
            if(this.responseMap[key] !== undefined && this.responseMap[key] !== "" && key !== this.questionMap.recommend){
                let qr = {
                    questionId: key,
                    responseValue: this.responseMap[key]
                };
                if(key === this.questionMap.dataProtection) {
                    qr.dataType = "Boolean";
                } else {
                    qr.dataType = "String";
                }
                responses.push(qr);
            }
        }

        let responsePayload = {
            responses: responses
        };
        console.log("responsePayload : " + JSON.stringify(responsePayload));

        if(responsePayload.responses === undefined || responsePayload.responses.length === 0) {
            console.log('No feedback provided');
            this.showNotification("Error", "Please provide feedback before submitting.", "error");
            return;
        }

        submitResponses({ responsesPayload: JSON.stringify(responsePayload), surveyResponseId: this.surveyResponseId})
        .then((result) => {
            console.log("result : " + JSON.stringify(result));
            this.showNotification("Thank You", "Your feedback has been submitted.", "success");
        })
        .catch((error) => {
            console.error(error);
            this.showNotification("Error", "Unable to submit feedback.", "error");
        }).finally(() => {
            this._showOptionalSection = false;
            this._showSpinner = false;
            this._showThankYou = true;
        });
    }

    submitNPSResponse() {
        console.log('Submitting NPS response');
        console.log("this.responseMap : " + JSON.stringify(this.responseMap));
        let npsResponsePayload = {
            questionId: this.questionMap.recommend,
            responseValue: this.responseMap[this.questionMap.recommend],
            dataType: "String"
        };

        submitNPSResponse({ responsesPayload: JSON.stringify(npsResponsePayload), surveyResponseId: this.surveyResponseId})
        .then((result) => {
            console.log("result : " + JSON.stringify(result));
            this.showNotification("Thank You", "Your feedback has been submitted.", "success");
        })
        .catch((error) => {
            console.error(error);
            this.showNotification("Error", "Unable to submit feedback.", "error");
        }).finally(() => {
            this._showOptionalSection = true;
            this._showSpinner = false;
            this._showNPS = false;
        });

        console.log("npsResponsePayload : " + JSON.stringify(npsResponsePayload));
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}