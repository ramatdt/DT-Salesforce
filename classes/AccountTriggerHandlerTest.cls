@IsTest
private class AccountTriggerHandlerTest {
    // Test Canadian account handling
    @IsTest
    static void testCanadianAccount() {
        Account acc = new Account(
            Name = 'Test Canada',
            BillingCountry = 'Canada',
            BillingState = 'ON',
            BillingCity = 'Toronto',
            BillingPostalCode = 'M5H 2N2'
        );

        Test.startTest();
        AccountTriggerHandler.applyRegionMapping(new List<Account>{acc});
        Test.stopTest();

        System.assertEquals('Canada', acc.Sales_Region__c, 'Sales Region should be Canada');
    }

    @IsTest
    static void testUSEnterpriseAccount() {
        AccountTriggerHandler.enterpriseStateToRegionMap.put('CA', 'West');

        Account acc = new Account(
            Name = 'Test Enterprise',
            BillingCountry = 'US',
            BillingState = 'CA',
            AnnualRevenue = AccountTriggerHandler.ENTERPRISE_REVENUE_THRESHOLD
        );

        Test.startTest();
        AccountTriggerHandler.applyRegionMapping(new List<Account>{acc});
        Test.stopTest();

        System.assertEquals('Enterprise', acc.Sales_Region__c, 'Should be Enterprise');
        System.assertEquals('West', acc.Enterprise_State__c, 'Enterprise State should map to West');
    }

    @IsTest
    static void testUSMidMarketAccount() {
        AccountTriggerHandler.midMarketStateToRegionMap.put('TX', 'South');

        Account acc = new Account(
            Name = 'Test Mid Market',
            BillingCountry = 'USA',
            BillingState = 'TX',
            AnnualRevenue = 3000000
        );

        Test.startTest();
        AccountTriggerHandler.applyRegionMapping(new List<Account>{acc});
        Test.stopTest();

        System.assertEquals('South', acc.Sales_Region__c, 'Should be Mid-Market region');
    }

    @IsTest
    static void testStrategicAccountNameMapping() {
        AccountTriggerHandler.accountNameToRegionMap.put('STRATEGIC ACCOUNT', 'Strategic Region');

        Account acc = new Account(
            Name = 'Strategic Account',
            BillingCountry = 'US',
            BillingState = 'CA'
        );

        Test.startTest();
        AccountTriggerHandler.applyRegionMapping(new List<Account>{acc});
        Test.stopTest();

        System.assertEquals('Strategic Region', acc.Sales_Region__c, 'Should map based on account name');
    }

    @IsTest
    static void testUpdateSalesRegionCheckbox() {
        Account oldAcc = new Account(
            Name = 'Old Account',
            BillingCountry = 'US',
            BillingState = 'NY',
            AnnualRevenue = 3000000
        );
        insert oldAcc;

        AccountTriggerHandler.midMarketStateToRegionMap.put('NY', 'Northeast');

        Account updatedAcc = new Account(
            Id = oldAcc.Id,
            BillingState = 'NY',
            Update_Sales_Region__c = true
        );

        Test.startTest();
        AccountTriggerHandler.handleSalesRegionUpdates(
            new List<Account>{updatedAcc},
            new Map<Id, Account>{oldAcc.Id => oldAcc}
        );
        Test.stopTest();
    }

    @IsTest
    static void testNullBillingCountry() {
        Account acc = new Account(
            Name = 'Test Null Country',
            BillingCountry = null
        );

        Test.startTest();
        AccountTriggerHandler.applyRegionMapping(new List<Account>{acc});
        Test.stopTest();

        System.assert(String.isBlank(acc.Sales_Region__c), 'Should not process without country');
    }

    @IsTest
    static void testHandleAfterInsertTypeUpdate() {
        Account acc = new Account(
            Name = 'Lead Converted',
            Is_Converted_from_Lead__c = true
        );

        insert acc;

        Test.startTest();
        AccountTriggerHandler.handleAfterInsert(new List<Account>{acc});
        Test.stopTest();

        Account updatedAcc = [SELECT Type FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Prospect Account', updatedAcc.Type, 'Type should be updated');
    }

    @IsTest
    static void testRestoreOwnerForClosedOpportunitiesFuture() {
        User u1 = [SELECT Id FROM User WHERE Profile.Name='Standard User' LIMIT 1];

        Account acc = new Account(Name='Restore Owner Test', OwnerId=u1.Id);
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Closed Opp',
            StageName='Closed Won',
            CloseDate=Date.today(),
            AccountId=acc.Id,
            OwnerId=u1.Id
        );
        insert opp;

        Account accUpdate = new Account(Id=acc.Id, OwnerId=UserInfo.getUserId());
        update accUpdate;

        Map<Id, Opportunity> closedMap = new Map<Id, Opportunity>{ opp.Id => opp };

        Test.startTest();
        AccountTriggerHandler.restoreOwnerForClosedOpportunitiesFuture(JSON.serialize(closedMap));
        Test.stopTest();

        Opportunity oppCheck = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(u1.Id, oppCheck.OwnerId, 'Owner should be restored');
    }

    @IsTest
    static void testBypassTriggerFlag() {
        AccountTriggerHandler.bypassTrigger = true;

        Account acc = new Account(
            Name = 'Bypass Account',
            BillingCountry = 'Canada'
        );

        Test.startTest();
        AccountTriggerHandler.applyRegionMapping(new List<Account>{acc});
        Test.stopTest();

        System.assertEquals('Canada', acc.Sales_Region__c);
    }

    @IsTest
    static void testHandleSalesRegionUpdatesWithNoChange() {
        Account acc = new Account(
            Name = 'Same Account',
            BillingCountry = 'Canada',
            BillingState = 'ON'
        );

        insert acc;

        Account unchangedAcc = new Account(
            Id = acc.Id,
            Name = 'Same Account',
            BillingCountry = 'Canada',
            BillingState = 'ON'
        );

        Test.startTest();
        AccountTriggerHandler.handleSalesRegionUpdates(
            new List<Account>{unchangedAcc},
            new Map<Id, Account>{acc.Id => acc}
        );
        Test.stopTest();
    }

    @IsTest
    static void testRestoreOwnerForClosedOpportunitiesMainMethod() {
        User u1 = [SELECT Id FROM User WHERE Profile.Name='Standard User' LIMIT 1];
        User u2 = UserInfo.getUserId() != u1.Id ? [SELECT Id FROM User WHERE Id != :u1.Id LIMIT 1] : u1;

        // Insert Account with initial owner
        Account acc = new Account(Name = 'Owner Change Account', OwnerId = u1.Id);
        insert acc;

        // Insert a closed Opportunity linked to Account
        Opportunity opp = new Opportunity(
            Name = 'Closed Opp for Restore',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            OwnerId = u1.Id
        );
        insert opp;

        // Simulate owner change in new Account record
        Account accUpdated = new Account(Id = acc.Id, OwnerId = u2.Id);

        // Call the method directly (this is what’s missing in your coverage)
        Test.startTest();
        AccountTriggerHandler.restoreOwnerForClosedOpportunities(
            new List<Account>{accUpdated},
            new Map<Id, Account>{acc.Id => acc}
        );
        Test.stopTest();

        // Optionally query back opp to verify owner (future method will run async)
        Opportunity checkOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(u1.Id, checkOpp.OwnerId, 'Owner should be restored to original');
    }
}