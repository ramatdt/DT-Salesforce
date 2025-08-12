@RestResource(urlMapping='/DKTravelVolume/*')
global with sharing class DKTravelVolumeRestHandler {

    @HttpDelete
    global static ResponseWrapper bulkDeleteByExternalIds() {
        // Debug checkpoint
        System.debug('### Starting bulkDeleteByExternalIds ###');
        
        // Initialize response
        ResponseWrapper response = new ResponseWrapper();
        response.successCount = 0;
        response.errors = new List<ErrorDetail>();
        
        try {            
            // Get external IDs from request
            List<String> externalIds = (List<String>)JSON.deserialize(
                RestContext.request.requestBody.toString(), 
                List<String>.class
            );
            
            // Validate input
            if(externalIds == null || externalIds.isEmpty()) {
                throw new CustomException('No external IDs provided');
            }
            
            // Chunk processing to avoid governor limits
            List<List<String>> batches = chunkList(externalIds, 200);
            
            for(List<String> batch : batches) {
                // Query records to delete
                Map<Id, DK_Volume__c> recordsToDelete = new Map<Id, DK_Volume__c>([
                    SELECT Id FROM DK_Volume__c 
                    WHERE DK_ExternalID__c IN :batch
                    LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows()
                ]);
                
                // Perform deletion with error tracking
                Database.DeleteResult[] results = Database.delete(
                    recordsToDelete.values(), 
                    false // Partial success
                );
                
                // Process results
                for(Integer i = 0; i < results.size(); i++) {
                    if(results[i].isSuccess()) {
                        response.successCount++;
                    } else {
                        response.errors.add(new ErrorDetail(
                            batch[i],
                            results[i].getErrors()[0].getMessage()
                        ));
                    }
                }
            }            
            System.debug('### Deletion completed: ' + response.successCount + ' successes ###');
            
        } catch(Exception e) {
            // Error handling
            System.debug('### Error: ' + e.getMessage() + ' ' + e.getStackTraceString());
            response.errors.add(new ErrorDetail('SYSTEM ERROR', e.getMessage()));
        }
        
        return response;
    }
    
    private static Boolean isValidSession(String sessionId, Id userId) {
        return [SELECT COUNT() FROM AuthSession 
                WHERE UsersId = :userId 
                AND SessionType = 'OAuth'
                AND IsCurrent = true] > 0;
    }
    
    private static List<List<String>> chunkList(List<String> inputList, Integer chunkSize) {
		List<List<String>> chunks = new List<List<String>>();
		for(Integer i = 0; i < inputList.size(); i += chunkSize) {
			List<String> batch = new List<String>();
			Integer endIndex = Math.min(i + chunkSize, inputList.size());
			
			for(Integer j = i; j < endIndex; j++) {
				batch.add(inputList[j]);
			}
			chunks.add(batch);
		}
		return chunks;
	}
    
    // Response wrapper class
    global class ResponseWrapper {
        public Integer successCount;
        public List<ErrorDetail> errors;
    }
    
    // Error detail class
    global class ErrorDetail {
        public String externalId;
        public String errorMessage;
        
        public ErrorDetail(String extId, String msg) {
            externalId = extId;
            errorMessage = msg;
        }
    }
    
    // Custom exception class
    class CustomException extends Exception {}

    @HttpPatch
    global static ResponseWrapperPatch bulkUpsertByExternalIds() {
        ResponseWrapperPatch responseWrapper = new ResponseWrapperPatch();
        responseWrapper.results = new List<ResultItem>();

        // Get field type information once
        Map<String, Schema.SObjectField> volumeFieldMap = Schema.SObjectType.DK_Volume__c.fields.getMap();

        try {
            // Parse the incoming JSON
            Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );
            List<Object> records = (List<Object>)requestBodyMap.get('records');

            // Process records and collect data for resolution
            List<ProcessRecord> processRecords = new List<ProcessRecord>();
            Set<String> accountNumbers = new Set<String>();
            Set<Id> accountIds = new Set<Id>();

            for (Object recordObj : records) {
                Map<String, Object> recordMap = (Map<String, Object>)recordObj;
                Map<String, Object> attributes = (Map<String, Object>)recordMap.get('attributes');
                String refId = (String)attributes.get('referenceId');

                ProcessRecord pr = new ProcessRecord();
                pr.referenceId = refId;
                pr.record = new DK_Volume__c();

                // Extract fields from JSON
                for (String fieldName : recordMap.keySet()) {
                    if (fieldName == 'attributes') continue;
                    
                    Object value = recordMap.get(fieldName);
                    
                    // Handle type conversions
                    if (volumeFieldMap.containsKey(fieldName)) {
                        Schema.DescribeFieldResult dfr = volumeFieldMap.get(fieldName).getDescribe();
                        Schema.DisplayType fieldType = dfr.getType();
                        
                        // Convert numbers to strings for string fields
                        if (fieldType == Schema.DisplayType.STRING && value != null) {
                            if (value instanceof Decimal || value instanceof Integer || value instanceof Double) {
                                value = String.valueOf(value);
                            }
                        }
                        // Convert string to date for date fields
                        if (fieldType == Schema.DisplayType.DATE && value != null && value instanceof String) {
                            try {
                                value = Date.valueOf((String)value);
                            } catch (Exception e) {
                                // Handle invalid date format
                                value = null; // or throw an error
                            }
                        }
                    }

                    if (fieldName == 'Account_Number__c') {
                        pr.accountNumber = (String)value; // Store number for lookup
                    } else if (fieldName == 'Account__c') {
                        pr.accountId = (String)value;
                        pr.record.put('Account__c', pr.accountId); // Set Account lookup
                    } else {
                        pr.record.put(fieldName, value); // Set other fields directly
                    }
                }
                processRecords.add(pr);

                // Collect unique identifiers for resolution
                if (pr.accountNumber != null) accountNumbers.add(pr.accountNumber);
                if (pr.accountId != null) accountIds.add(pr.accountId);
            }

            // Resolve Account_Number__c using external ID (Account_Number__c)
            Map<String, Id> accountNumberIdMap = new Map<String, Id>();
            if (!accountNumbers.isEmpty()) {
                for (Account_Number__c accNum : [
                    SELECT Id, Account_Number__c 
                    FROM Account_Number__c 
                    WHERE Account_Number__c IN :accountNumbers
                ]) {
                    accountNumberIdMap.put(accNum.Account_Number__c, accNum.Id);
                }
            }

            // Validate Account__c existence
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id FROM Account WHERE Id IN :accountIds
            ]);

            // Validate records and prepare for upsert
            List<DK_Volume__c> validRecords = new List<DK_Volume__c>();
            List<ProcessRecord> validProcessRecords = new List<ProcessRecord>();

            for (ProcessRecord pr : processRecords) {
                // Reset validation flags
                pr.hasAccountNumberError = false;
                pr.hasAccountError = false;

                // Validate Account_Number__c (resolve to ID)
                if (pr.accountNumber != null) {
                    if (accountNumberIdMap.containsKey(pr.accountNumber)) {
                        pr.record.Account_Number__c = accountNumberIdMap.get(pr.accountNumber);
                    } else {
                        pr.hasAccountNumberError = true;
                        pr.accountNumberError = 'Account Number not found: ' + pr.accountNumber;
                    }
                } else {
                    pr.hasAccountNumberError = true;
                    pr.accountNumberError = 'Account Number is required';
                }

                // Validate Account__c
                if (pr.accountId != null && !accountMap.containsKey(pr.accountId)) {
                    pr.hasAccountError = true;
                    pr.accountError = 'Account not found: ' + pr.accountId;
                }

                // Add to valid records if no errors
                if (!pr.hasAccountNumberError && !pr.hasAccountError) {
                    validRecords.add(pr.record);
                    validProcessRecords.add(pr);
                }
            }

            // Chunk processing for upsert (200 records per chunk)
            Map<String, Database.UpsertResult> resultsByRefId = new Map<String, Database.UpsertResult>();
            
            // Handle empty valid records case
            if (!validRecords.isEmpty()) {
                List<List<DK_Volume__c>> recordChunks = chunkVolumeList(validRecords, 200);
                List<List<ProcessRecord>> processRecordChunks = chunkProcessRecordList(validProcessRecords, 200);

                for (Integer i = 0; i < recordChunks.size(); i++) {
                    List<DK_Volume__c> chunk = recordChunks[i];
                    List<ProcessRecord> prChunk = processRecordChunks[i];
                    
                    Database.UpsertResult[] chunkResults = Database.upsert(
                        chunk, 
                        DK_Volume__c.DK_ExternalID__c, 
                        false // Partial success
                    );
                    
                    // Map results to reference IDs
                    for (Integer j = 0; j < chunkResults.size(); j++) {
                        resultsByRefId.put(prChunk[j].referenceId, chunkResults[j]);
                    }
                }
            }

            // Build response
            for (ProcessRecord pr : processRecords) {
                ResultItem item = new ResultItem();
                item.referenceId = pr.referenceId;
                
                if (pr.hasAccountNumberError || pr.hasAccountError) {
                    // Pre-validation errors
                    item.success = false;
                    item.salesforceId = null;
                    item.errors = new List<String>();
                    if (pr.hasAccountNumberError) item.errors.add(pr.accountNumberError);
                    if (pr.hasAccountError) item.errors.add(pr.accountError);
                    item.created = false;
                } else {
                    // Upsert results
                    Database.UpsertResult result = resultsByRefId.get(pr.referenceId);
                    if (result != null) {
                        item.success = result.isSuccess();
                        if (result.isSuccess()) {
                            item.salesforceId = result.getId();
                            item.created = result.isCreated();
                            item.errors = new List<String>();
                        } else {
                            item.salesforceId = null;
                            item.created = false;
                            item.errors = new List<String>();
                            for (Database.Error err : result.getErrors()) {
                                item.errors.add(err.getMessage());
                            }
                        }
                    } else {
                        // Handle case where result is missing
                        item.success = false;
                        item.salesforceId = null;
                        item.errors = new List<String>{ 'Upsert operation did not return a result' };
                        item.created = false;
                    }
                }
                responseWrapper.results.add(item);
            }

        } catch (Exception e) {
            // Handle system errors
            ResultItem item = new ResultItem();
            item.referenceId = 'SYSTEM_ERROR';
            item.success = false;
            item.salesforceId = null;
            item.errors = new List<String>{ 
                'System error: ' + e.getMessage() + ' at ' + e.getStackTraceString() 
            };
            item.created = false;
            responseWrapper.results.add(item);
        }

        return responseWrapper;
    }

    // Chunking methods
    private static List<List<DK_Volume__c>> chunkVolumeList(List<DK_Volume__c> inputList, Integer chunkSize) {
        List<List<DK_Volume__c>> chunks = new List<List<DK_Volume__c>>();
        for (Integer i = 0; i < inputList.size(); i += chunkSize) {
            List<DK_Volume__c> batch = new List<DK_Volume__c>();
            Integer endIndex = Math.min(i + chunkSize, inputList.size());
            for (Integer j = i; j < endIndex; j++) {
                batch.add(inputList[j]);
            }
            chunks.add(batch);
        }
        return chunks;
    }

    private static List<List<ProcessRecord>> chunkProcessRecordList(List<ProcessRecord> inputList, Integer chunkSize) {
        List<List<ProcessRecord>> chunks = new List<List<ProcessRecord>>();
        for (Integer i = 0; i < inputList.size(); i += chunkSize) {
            List<ProcessRecord> batch = new List<ProcessRecord>();
            Integer endIndex = Math.min(i + chunkSize, inputList.size());
            for (Integer j = i; j < endIndex; j++) {
                batch.add(inputList[j]);
            }
            chunks.add(batch);
        }
        return chunks;
    }

    // Inner classes for PATCH processing
    global class ResponseWrapperPatch {
        global List<ResultItem> results;
    }

    global class ResultItem {
        global String referenceId;
        global String salesforceId;
        global Boolean success;
        global List<String> errors;
        global Boolean created;
    }

    private class ProcessRecord {
        String referenceId;
        DK_Volume__c record;
        String accountNumber;   // Account Number from JSON
        Id accountId;           // Account ID from JSON
        Boolean hasAccountNumberError = false;
        Boolean hasAccountError = false;
        String accountNumberError;
        String accountError;
    }
}