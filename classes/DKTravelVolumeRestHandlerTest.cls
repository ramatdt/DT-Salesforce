@isTest
private class DKTravelVolumeRestHandlerTest {    
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

		Account_Number__c validAcc = new Account_Number__c(Account_Number__c = '001', Account__c = accnt.Id);
        insert validAcc;

        List<DK_Volume__c> dkTravel = new List<DK_Volume__c>();
        for (Integer i = 0; i < 3; i++) {
            dkTravel.add(new DK_Volume__c(
                DK_ExternalID__c = '001' + i,
				Account_Number__c = validAcc.Id
            ));
        }
        insert dkTravel;

        // Extract external IDs
        List<String> extIds = new List<String>();
        for (DK_Volume__c dk : dkTravel) {
            extIds.add(dk.DK_ExternalID__c);
        }

        // Serialize input and set request context
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(extIds));

        // Call method
        DKTravelVolumeRestHandler.ResponseWrapper response = DKTravelVolumeRestHandler.bulkDeleteByExternalIds();
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

        DK_Volume__c validDk = new DK_Volume__c(DK_ExternalID__c = '001', Account_Number__c = validAcc.Id);
        insert validDk;

        // Include one valid and one non-existent external ID
        List<String> extIds = new List<String>{'001', '999'};

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(extIds));

        DKTravelVolumeRestHandler.ResponseWrapper response = DKTravelVolumeRestHandler.bulkDeleteByExternalIds();
    }

    @isTest
    static void testBulkDeleteByExternalIds_NoIdsProvided() {
        List<String> extIds = new List<String>();

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(extIds));

        DKTravelVolumeRestHandler.ResponseWrapper response = DKTravelVolumeRestHandler.bulkDeleteByExternalIds();

        // Should throw an exception and capture in response errors
        System.assertEquals(0, response.successCount);
        System.assertEquals(1, response.errors.size());
        System.assertEquals('SYSTEM ERROR', response.errors[0].externalId);
        System.assert(response.errors[0].errorMessage.contains('No external IDs provided'), 'Should include input validation error');
    }

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCountry = 'USA',
            BillingState = 'CA',
            BillingCity = 'San Francisco',
            BillingPostalCode = '94105'
        );
        insert acc;

        // Create Account_Number__c (external ID)
        Account_Number__c accNum = new Account_Number__c(
            Account_Number__c = 'ACC-001',
            Account__c = acc.Id
        );
        insert accNum;

        // Create existing DK_Volume__c for update scenario
        DK_Volume__c dkExisting = new DK_Volume__c(
            DK_ExternalID__c = 'EXT-001',
            Account_Number__c = accNum.Id,
            Account__c = acc.Id
        );
        insert dkExisting;
    }

    @isTest
    static void testBulkUpsertByExternalIds_Success_CreateAndUpdate() {
        // Fetch IDs for reference
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account_Number__c accNum = [SELECT Id, Account_Number__c FROM Account_Number__c LIMIT 1];
        DK_Volume__c dkExisting = [SELECT Id, DK_ExternalID__c FROM DK_Volume__c WHERE DK_ExternalID__c = 'EXT-001' LIMIT 1];

        // Prepare records: one update, one insert
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        records.add(new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-update' },
            'DK_ExternalID__c' => 'EXT-001',
            'Account_Number__c' => accNum.Account_Number__c,
            'Account__c' => acc.Id,
            'Name' => 'Updated Name'
        });
        records.add(new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-insert' },
            'DK_ExternalID__c' => 'EXT-002',
            'Account_Number__c' => accNum.Account_Number__c,
            'Account__c' => acc.Id,
            'Name' => 'New Insert'
        });

        Map<String, Object> requestBody = new Map<String, Object>{ 'records' => records };
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();

        // Call PATCH method
        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();

        Map<String, DKTravelVolumeRestHandler.ResultItem> byRef = new Map<String, DKTravelVolumeRestHandler.ResultItem>();
        for (DKTravelVolumeRestHandler.ResultItem item : response.results) {
            byRef.put(item.referenceId, item);
        }
    }

    @isTest
    static void testBulkUpsertByExternalIds_AccountNumberNotFound() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Account Number does not exist
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        records.add(new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-missing' },
            'DK_ExternalID__c' => 'EXT-003',
            'Account_Number__c' => 'DOES-NOT-EXIST',
            'Account__c' => acc.Id,
            'Name' => 'Should Fail'
        });

        Map<String, Object> requestBody = new Map<String, Object>{ 'records' => records };
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();

        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();
    }

    @isTest
    static void testBulkUpsertByExternalIds_AccountIdNotFound() {
        Account_Number__c accNum = [SELECT Account_Number__c FROM Account_Number__c LIMIT 1];

        // Account__c does not exist
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        records.add(new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-badacc' },
            'DK_ExternalID__c' => 'EXT-004',
            'Account_Number__c' => accNum.Account_Number__c,
            'Account__c' => '001XXXXXXXXXXXXXXX', // Invalid Salesforce ID
            'Name' => 'Should Fail'
        });

        Map<String, Object> requestBody = new Map<String, Object>{ 'records' => records };
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();

        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();
    }

    @isTest
    static void testBulkUpsertByExternalIds_MissingAccountNumberField() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Missing Account_Number__c field
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        records.add(new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-missingfield' },
            'DK_ExternalID__c' => 'EXT-005',
            'Account__c' => acc.Id,
            'Name' => 'Should Fail'
        });

        Map<String, Object> requestBody = new Map<String, Object>{ 'records' => records };
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();

        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();
    }

    @isTest
    static void testBulkUpsertByExternalIds_SystemError() {
        // Send completely invalid JSON to force exception
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('not a json');
        RestContext.response = new RestResponse();

        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();

        // Should return a system error
        System.assertEquals(1, response.results.size());
        System.assertEquals('SYSTEM_ERROR', response.results[0].referenceId);
        System.assertEquals(false, response.results[0].success);
        System.assert(response.results[0].errors[0].contains('System error'), 'Should report a system error');
    }

    @isTest
    static void testBulkUpsert_MixedResults() {
        // Setup
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account_Number__c validAccNum = [SELECT Account_Number__c FROM Account_Number__c LIMIT 1];
        
        // Prepare records with mixed validity
        List<Map<String, Object>> records = new List<Map<String, Object>>{
            // Valid record (update)
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-valid' },
                'DK_ExternalID__c' => 'EXT-001',
                'Account_Number__c' => validAccNum.Account_Number__c,
                'Account__c' => acc.Id,
                'Name' => 'Updated Name'
            },
            // Invalid Account Number
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-badAccNum' },
                'DK_ExternalID__c' => 'EXT-002',
                'Account_Number__c' => 'INVALID-ACC-NUM',
                'Account__c' => acc.Id
            },
            // Invalid Account ID
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-badAccId' },
                'DK_ExternalID__c' => 'EXT-003',
                'Account_Number__c' => validAccNum.Account_Number__c,
                'Account__c' => '001000000000000' // Invalid ID
            }
        };
        
        // Execute
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{ 'records' => records }));
        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();
    }

    @isTest
    static void testBulkUpsert_TypeConversion() {
        // Setup
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account_Number__c validAccNum = [SELECT Account_Number__c FROM Account_Number__c LIMIT 1];
        
        // Prepare records with type conversion scenarios
        List<Map<String, Object>> records = new List<Map<String, Object>>{
            // String to Date conversion
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-date' },
                'DK_ExternalID__c' => 'EXT-DATE',
                'Account_Number__c' => validAccNum.Account_Number__c,
                'Account__c' => acc.Id,
                'Travel_Date__c' => '2023-12-31' // Valid ISO date
            },
            // Number to String conversion
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-string' },
                'DK_ExternalID__c' => 'EXT-STRING',
                'Account_Number__c' => validAccNum.Account_Number__c,
                'Account__c' => acc.Id,
                'Description__c' => 12345 // Number to String field
            }
        };
        
        // Execute
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{ 'records' => records }));
        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();
    }

    @isTest
    static void testBulkUpsert_ChunkProcessing() {
        // Setup
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account_Number__c validAccNum = [SELECT Account_Number__c FROM Account_Number__c LIMIT 1];
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        
        // Create 3 records to test chunking (chunk size=2)
        for (Integer i = 1; i <= 3; i++) {
            records.add(new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-' + i },
                'DK_ExternalID__c' => 'EXT-CHUNK-' + i,
                'Account_Number__c' => validAccNum.Account_Number__c,
                'Account__c' => acc.Id
            });
        }
        
        // Execute
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{ 'records' => records }));
        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();
        
        // Assert
        System.assertEquals(3, response.results.size(), 'Should process all records');
        for (DKTravelVolumeRestHandler.ResultItem item : response.results) {
            System.assert(item.success, 'All records should succeed: ' + item.errors);
        }
        System.assertEquals(3, [SELECT COUNT() FROM DK_Volume__c WHERE DK_ExternalID__c LIKE 'EXT-CHUNK-%'], 'Records should be inserted');
    }

    @isTest
    static void testBulkUpsert_ValidationErrors() {
        // Setup
        List<Map<String, Object>> records = new List<Map<String, Object>>{
            // Missing Account Number
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-missingAccNum' },
                'DK_ExternalID__c' => 'EXT-ERR-1',
                'Account__c' => '001000000000000' // Account Number missing
            },
            // Missing Account ID
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'referenceId' => 'ref-missingAccId' },
                'DK_ExternalID__c' => 'EXT-ERR-2',
                'Account_Number__c' => 'ACC-001' // Account ID missing
            }
        };
        
        // Execute
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{ 'records' => records }));
        DKTravelVolumeRestHandler.ResponseWrapperPatch response = DKTravelVolumeRestHandler.bulkUpsertByExternalIds();
    }

}