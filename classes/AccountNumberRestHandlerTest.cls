@isTest
private class AccountNumberRestHandlerTest {
    
    @isTest
    static void testBulkDeleteByExternalIds_Success() {
        // Prepare test data
        Account accnt = new Account(
            Name = 'Test Mid Market',
            BillingCountry = 'USA',
            BillingState = 'TX',
            Prospect_Spend_Air__c = 3000000,
            BillingCity = 'Austin',
            BillingPostalCode = '73301'
        );
        insert accnt;

        // Prepare Account_Number__c records with required Account__c field
        List<Account_Number__c> accountNumbers = new List<Account_Number__c>();
        for (Integer i = 0; i < 3; i++) {
            accountNumbers.add(new Account_Number__c(
                Account_Number__c = '001' + i,
                Account__c = accnt.Id
            ));
        }
        insert accountNumbers;

        // Extract external IDs
        List<String> extIds = new List<String>();
        for (Account_Number__c acc : accountNumbers) {
            extIds.add(acc.Account_Number__c);
        }

        // Serialize input and set request context
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(extIds));

        // Call method
        AccountNumberRestHandler.ResponseWrapper response = AccountNumberRestHandler.bulkDeleteByExternalIds();

        // Assertions
        System.assertEquals(3, response.successCount, 'All records should be deleted');
        System.assertEquals(0, response.errors.size(), 'No errors should be present');
    }

    @isTest
    static void testBulkDeleteByExternalIds_PartialFailure() {
        Account accnt = new Account(
            Name = 'Test Mid Market',
            BillingCountry = 'USA',
            BillingState = 'TX',
            Prospect_Spend_Air__c = 3000000,
            BillingCity = 'Austin',
            BillingPostalCode = '73301'
        );
        insert accnt;

        Account_Number__c validAcc = new Account_Number__c(Account_Number__c = '001', Account__c = accnt.Id);
        insert validAcc;

        // Include one valid and one non-existent external ID
        List<String> extIds = new List<String>{'001', '999'};

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(extIds));

        AccountNumberRestHandler.ResponseWrapper response = AccountNumberRestHandler.bulkDeleteByExternalIds();
    }

    @isTest
    static void testBulkDeleteByExternalIds_NoIdsProvided() {
        List<String> extIds = new List<String>();

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(extIds));

        AccountNumberRestHandler.ResponseWrapper response = AccountNumberRestHandler.bulkDeleteByExternalIds();

        // Should throw an exception and capture in response errors
        System.assertEquals(0, response.successCount);
        System.assertEquals(1, response.errors.size());
        System.assertEquals('SYSTEM ERROR', response.errors[0].externalId);
        System.assert(response.errors[0].errorMessage.contains('No external IDs provided'), 'Should include input validation error');
    }

    @isTest
    static void testBulkUpsertByExternalIds_PartialFailure() {
        // Prepare request with valid and invalid records
        List<Map<String, Object>> records = new List<Map<String, Object>>{
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{'referenceId' => 'REF1'},
                'Account__c' => createTestAccount().Id,
                'Account_Number__c' => 'VALID_001' // Valid
            }
        };

        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{'records' => records}));

        Test.startTest();
            AccountNumberRestHandler.UpsertResponseWrapper response = AccountNumberRestHandler.bulkUpsertByExternalIds();
        Test.stopTest();
    }

    @isTest
    static void testBulkUpsertByExternalIds_InvalidInput() {
        // Test empty records
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'records' => new List<Object>()
        }));

        AccountNumberRestHandler.UpsertResponseWrapper response = AccountNumberRestHandler.bulkUpsertByExternalIds();
        System.assertEquals(1, response.results.size());
        System.assert(response.results[0].errors[0].contains('No records provided'), 'Should handle empty input');

        // Test malformed JSON
        RestContext.request.requestBody = Blob.valueOf('{"invalid": "format"}');
        response = AccountNumberRestHandler.bulkUpsertByExternalIds();
    }

    @isTest
    static void testBulkUpsertByExternalIds_SystemException() {
        // Force null pointer exception
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('{"records": [{"invalid": "structure"}]}');

        AccountNumberRestHandler.UpsertResponseWrapper response = AccountNumberRestHandler.bulkUpsertByExternalIds();
    }

    private static Account createTestAccount() {
        Account acc = new Account(
            Name = 'Test12434 Account1234',
            BillingCountry = 'US',
            BillingPostalCode = '12345'
        );
        insert acc;
        return acc;
    }

}