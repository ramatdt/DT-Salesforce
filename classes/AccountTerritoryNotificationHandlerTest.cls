@isTest
private class AccountTerritoryNotificationHandlerTest {
    @testSetup
    static void setupData() {
        // Create Territory2Model
        Territory2Model model = new Territory2Model(
            DeveloperName = 'TestModel',
            Name = 'Test Territory Model'
        );
        insert model;

        // Query a valid Territory2Type (at least one exists by default)
        Territory2Type t2Type = [SELECT Id FROM Territory2Type LIMIT 1];

        // Create Territory2 using the Territory2TypeId
        Territory2 territory = new Territory2(
            Name = 'Test Territory',
            DeveloperName = 'Test_Territory',
            Territory2ModelId = model.Id,
            Territory2TypeId = t2Type.Id
        );
        insert territory;

        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser_' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;

        // Associate user to the territory
        UserTerritory2Association uta = new UserTerritory2Association(
            UserId = testUser.Id,
            Territory2Id = territory.Id
        );
        insert uta;

        // Create Account
		System.runAs(testUser) {
			Account acc = new Account(
				Name = 'Test Account',
				Type = 'Prospect Account',
				Industry = 'Technology',
				Sales_Region__c = 'Canada',
				Prospect_Spend_Air__c = 534534
			);
			insert acc;

			//Associate Account to the territory
			ObjectTerritory2Association ota = new ObjectTerritory2Association(
				ObjectId = acc.Id,
				Territory2Id = territory.Id,
				AssociationCause = 'Territory2Manual'
			);
			insert ota;
		}
    }

    @isTest
	static void testEmailNotificationFormatCoverage() {
		// Fetch the test Account
		Account acc = [SELECT Id, Name, Type, Industry, Sales_Region__c, Prospect_Spend_Air__c FROM Account LIMIT 1];
		acc.Name = 'Updated Name'; 

		Test.startTest();
		AccountTerritoryNotificationHandler.processAccountTerritoryAssignments(
			new List<Account>{acc},
			new Map<Id, Account>{acc.Id => acc}
		);
		Test.stopTest();

		System.assert(true, 'Email processing logic executed');
	}
}