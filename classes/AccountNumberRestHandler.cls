@RestResource(urlMapping='/AccountNumber/*')
global with sharing class AccountNumberRestHandler {

    @HttpDelete
    global static ResponseWrapper bulkDeleteByExternalIds() {
        System.debug('### Starting bulkDeleteByExternalIds ###');
        
        ResponseWrapper response = new ResponseWrapper();
        response.successCount = 0;
        response.errors = new List<ErrorDetail>();
        
        try {            
            List<String> externalIds = (List<String>)JSON.deserialize(
                RestContext.request.requestBody.toString(), 
                List<String>.class
            );
            
            if(externalIds == null || externalIds.isEmpty()) {
                throw new CustomException('No external IDs provided');
            }
            
            List<List<String>> batches = chunkList(externalIds, 200);
            
            for(List<String> batch : batches) {
                Map<Id, Account_Number__c> recordsToDelete = new Map<Id, Account_Number__c>([
                    SELECT Id FROM Account_Number__c 
                    WHERE Account_Number__c IN :batch
                    LIMIT :Limits.getLimitQueryRows() - Limits.getQueryRows()
                ]);
                
                Database.DeleteResult[] results = Database.delete(
                    recordsToDelete.values(), 
                    false
                );
                
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
            System.debug('### Error: ' + e.getMessage() + ' ' + e.getStackTraceString());
            response.errors.add(new ErrorDetail('SYSTEM ERROR', e.getMessage()));
        }
        
        return response;
    }

    @HttpPatch
    global static UpsertResponseWrapper bulkUpsertByExternalIds() {
        System.debug('### Starting bulkUpsertByExternalIds ###');
        
        UpsertResponseWrapper response = new UpsertResponseWrapper();
        response.results = new List<UpsertResult>();
        
        try {
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );
            
            List<Object> recordsList = (List<Object>)requestMap.get('records');
            if(recordsList == null || recordsList.isEmpty()) {
                throw new CustomException('No records provided in request body');
            }
            
            List<RecordData> recordsData = new List<RecordData>();
            for(Object recObj : recordsList) {
                Map<String, Object> recMap = (Map<String, Object>)recObj;
                Map<String, Object> attributes = (Map<String, Object>)recMap.get('attributes');
                
                if(attributes == null) {
                    throw new CustomException('Missing attributes in record');
                }
                
                RecordData data = new RecordData();
                data.referenceId = (String)attributes.get('referenceId');
                data.accountId = (String)recMap.get('Account__c');
                data.accountNumber = (String)recMap.get('Account_Number__c');
                data.currencyIsoCode = (String)recMap.get('CurrencyIsoCode'); // Extract currency
                
                if(data.referenceId == null) {
                    throw new CustomException('Missing referenceId in attributes');
                }
                if(data.accountNumber == null) {
                    throw new CustomException('Account_Number__c is required for record: ' + data.referenceId);
                }
                
                recordsData.add(data);
            }
            
            Map<String, Account_Number__c> refIdToRecord = new Map<String, Account_Number__c>();
            List<String> externalIds = new List<String>();
            
            for(RecordData data : recordsData) {
                Account_Number__c accNum = new Account_Number__c(
                    Account_Number__c = data.accountNumber,
                    Account__c = data.accountId
                );
                
                if(String.isNotBlank(data.currencyIsoCode)) {
                    accNum.CurrencyIsoCode = data.currencyIsoCode;
                }
                
                refIdToRecord.put(data.referenceId, accNum);
                externalIds.add(data.accountNumber);
            }
            
            Map<String, Account_Number__c> existingRecordsMap = new Map<String, Account_Number__c>();
            for(Account_Number__c existing : [
                SELECT Id, Account_Number__c 
                FROM Account_Number__c 
                WHERE Account_Number__c IN :externalIds
            ]) {
                existingRecordsMap.put(existing.Account_Number__c, existing);
            }
            
            for(String refId : refIdToRecord.keySet()) {
                Account_Number__c rec = refIdToRecord.get(refId);
                if(existingRecordsMap.containsKey(rec.Account_Number__c)) {
                    rec.Id = existingRecordsMap.get(rec.Account_Number__c).Id;
                }
            }
            
            List<List<Account_Number__c>> batches = chunkRecords(refIdToRecord.values(), 200);
            Map<String, Database.UpsertResult> refIdToResult = new Map<String, Database.UpsertResult>();
            
            for(List<Account_Number__c> batch : batches) {
                Database.UpsertResult[] results = Database.upsert(
                    batch, 
                    Account_Number__c.Fields.Account_Number__c, 
                    false
                );
                
                for(Integer i = 0; i < batch.size(); i++) {
                    String externalId = batch[i].Account_Number__c;
                    String refId = findRefIdByExternalId(refIdToRecord, externalId);
                    if(refId != null) {
                        refIdToResult.put(refId, results[i]);
                    }
                }
            }
            
            for(String refId : refIdToRecord.keySet()) {
                UpsertResult res = new UpsertResult();
                res.referenceId = refId;
                
                if(refIdToResult.containsKey(refId)) {
                    Database.UpsertResult ur = refIdToResult.get(refId);
                    res.success = ur.isSuccess();
                    res.created = ur.isCreated();
                    res.salesforceId = ur.isSuccess() ? ur.getId() : null;
                    res.errors = new List<String>();
                    
                    if(!ur.isSuccess()) {
                        for(Database.Error err : ur.getErrors()) {
                            res.errors.add(err.getMessage());
                        }
                    }
                } else {
                    res.success = false;
                    res.created = false;
                    res.errors = new List<String>{'Record not processed'};
                }
                response.results.add(res);
            }
            
        } catch(Exception e) {
            System.debug('### Error: ' + e.getMessage() + ' ' + e.getStackTraceString());
            UpsertResult errorRes = new UpsertResult();
            errorRes.referenceId = 'SYSTEM_ERROR';
            errorRes.success = false;
            errorRes.created = false;
            errorRes.errors = new List<String>{ e.getMessage() };
            response.results.add(errorRes);
        }
        
        return response;
    }

    private class RecordData {
        public String referenceId;
        public String accountId;
        public String accountNumber;
        public String currencyIsoCode;
    }

    private static String findRefIdByExternalId(Map<String, Account_Number__c> refIdToRecord, String externalId) {
        for(String refId : refIdToRecord.keySet()) {
            if(refIdToRecord.get(refId).Account_Number__c == externalId) {
                return refId;
            }
        }
        return null;
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

    private static List<List<Account_Number__c>> chunkRecords(List<Account_Number__c> records, Integer chunkSize) {
        List<List<Account_Number__c>> chunks = new List<List<Account_Number__c>>();
        for(Integer i = 0; i < records.size(); i += chunkSize) {
            List<Account_Number__c> chunk = new List<Account_Number__c>();
            Integer endIndex = Math.min(i + chunkSize, records.size());
            for(Integer j = i; j < endIndex; j++) {
                chunk.add(records[j]);
            }
            chunks.add(chunk);
        }
        return chunks;
    }

    global class ResponseWrapper {
        public Integer successCount;
        public List<ErrorDetail> errors;
    }

    global class ErrorDetail {
        public String externalId;
        public String errorMessage;
        public ErrorDetail(String extId, String msg) {
            externalId = extId;
            errorMessage = msg;
        }
    }

    global class UpsertResponseWrapper {
        public List<UpsertResult> results;
    }

    global class UpsertResult {
        public String referenceId;
        public String salesforceId;
        public Boolean success;
        public Boolean created;
        public List<String> errors;
    }

    private class CustomException extends Exception {}
}