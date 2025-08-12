@isTest
private class addupdateTravelVolumeTest {
    @isTest static void TestUpdate() {
        // Test data setup
        // Create an account with an opportunity, and then try to delete it
        // 
        Account acct = new Account(Name='Test Account', Type='Central Client', Region__c='Central', AccountSource='ATPI', Industry='Accounting');
        insert acct;
        
        Account_Number__c acctNum = new Account_Number__c(Account__c=acct.ID, Account_Number__c='1234567890');
        insert acctNum;
        
        Travel_Volume__c tvol = new Travel_Volume__c(Account__c=acct.id, Reported_Month__c='01', Reported_Year__c='2020');
        insert tvol;
        
        DK_Volume__c dkvol = new DK_Volume__c(Account_Number__c=acctNum.ID, Reported_Month__c='01', Reported_Year__c='2020');
        insert dkvol;
   
    }
    
}