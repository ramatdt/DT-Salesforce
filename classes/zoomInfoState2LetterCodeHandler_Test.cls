/**
    To cover class: Convert State Names to 2 Letter Codes Trigger
 */
@isTest
private class zoomInfoState2LetterCodeHandler_Test {

    static testMethod void coverzoomInfoAccountFieldhandler() {

        Account a = new Account();
        a.Name = 'TestMethod';
        
        a.BillingStreet = '123 Waverlay Oaks Road';
        a.BillingCity = 'Waltham';
        a.BillingState = 'Massachusetts';
        a.BillingPostalCode = '84370';
        a.BillingCountry = 'United States';       
        a.Region__c = 'East';      
        
        insert a;

    //a = [Select Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account where id = :a.Id];

    //System.AssertEquals(a.BillingState, 'MA');

    // Update Values to Check Update Triggers       

        a.BillingState = 'Wyoming';
                
        update a;        
    }

    static testMethod void coverzoomInfoContactFieldhandler() {

        Account a = new Account();
        a.Name = 'TestMethod';       
        a.BillingStreet = '123 Waverlay Oaks Road';
        a.BillingCity = 'Waltham';
        a.BillingState = 'Massachusetts';
        a.BillingPostalCode = '84370';
        a.BillingCountry = 'United States';       
        a.Region__c = 'East';       
        insert a;

    Contact c = new Contact();
    c.LastName = 'TestMethod';
        c.MailingState = 'Massachusetts';
    insert c;

        c.MailingState = 'Wyoming';
    update c;   
        
    }

    static testMethod void coverzoomInfoLeadFieldhandler() {

        Lead a = new Lead();
        a.lastName = 'TestMethod';
    a.Company = 'ZoomInfo';    
        a.Street = '123 Waverlay Oaks Road';
        a.City = 'Waltham';
        a.State = 'Massachusetts';
        a.PostalCode = '84370';
        a.Country = 'United States';       
        a.Prospect_Spend_Air_Comment__c = 'East';
        insert a;

        a.State = 'Wyoming';
                
        update a;
        
    }
}