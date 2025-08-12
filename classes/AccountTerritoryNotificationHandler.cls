public with sharing class AccountTerritoryNotificationHandler {
    public static void processAccountTerritoryAssignments(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : newList) {
            accountIds.add(acc.Id);
        }

        // Get Territory assignments for Accounts
        List<ObjectTerritory2Association> accountTerritoryAssociations = [
            SELECT Id, ObjectId, Territory2Id
            FROM ObjectTerritory2Association
            WHERE ObjectId IN :accountIds
        ];

        Map<Id, List<Id>> accountToTerritoryMap = new Map<Id, List<Id>>();
        Set<Id> territoryIds = new Set<Id>();
        for (ObjectTerritory2Association assoc : accountTerritoryAssociations) {
            if (!accountToTerritoryMap.containsKey(assoc.ObjectId)) {
                accountToTerritoryMap.put(assoc.ObjectId, new List<Id>());
            }
            accountToTerritoryMap.get(assoc.ObjectId).add(assoc.Territory2Id);
            territoryIds.add(assoc.Territory2Id);
        }

        Map<Id, List<User>> territoryToUsersMap = getUsersByTerritory(territoryIds);

        // Query relevant fields from Account
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Name, Type, Industry, Sales_Region__c, Prospect_Spend_Air__c
            FROM Account 
            WHERE Id IN :accountIds
        ]);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id accId : accountToTerritoryMap.keySet()) {
            Account acc = accountMap.get(accId);
            for (Id terrId : accountToTerritoryMap.get(accId)) {
                List<User> users = territoryToUsersMap.get(terrId);
                if (users != null) {
                    for (User u : users) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(u.Id);
                        mail.setSaveAsActivity(false);
                        mail.setSubject(formatSubject(acc));
                        mail.setHtmlBody(formatBody(acc));
                        mail.setSenderDisplayName('Territory Notification');
                        emails.add(mail);

						System.debug('Prepared email to: ' + u.Email + ' for Account: ' + acc.Name);
                    	System.debug('Email Subject: ' + formatSubject(acc));
                    	System.debug('Email Body: ' + formatBody(acc));
                    }
                }
            }
        }

        if (!emails.isEmpty()) {
			Messaging.SendEmailResult[] results = Messaging.sendEmail(emails, false);
			for (Integer i = 0; i < results.size(); i++) {
				if (results[i].isSuccess()) {
					System.debug('Email sent successfully to: ' + emails[i].getToAddresses());
				} else {
					System.debug('Failed to send email to: ' + emails[i].getToAddresses() + 
								' | Errors: ' + results[i].getErrors()[0].getMessage());
				}
			}
		} else {
			System.debug('No emails prepared to send.');
		}
    }

    private static Map<Id, List<User>> getUsersByTerritory(Set<Id> territoryIds) {
        Map<Id, List<User>> result = new Map<Id, List<User>>();
        List<UserTerritory2Association> assocList = [
            SELECT UserId, Territory2Id, User.FirstName, User.Email 
            FROM UserTerritory2Association 
            WHERE Territory2Id IN :territoryIds AND IsActive = true
        ];
        for (UserTerritory2Association uta : assocList) {
            if (!result.containsKey(uta.Territory2Id)) {
                result.put(uta.Territory2Id, new List<User>());
            }
            result.get(uta.Territory2Id).add(uta.User);
        }
        return result;
    }

    // Helper to format email subject
	@TestVisible
    private static String formatSubject(Account acc) {
        return 'Account Assigned to Territory: ' + acc.Name + ' | ' + acc.Type + ' | ' + acc.Sales_Region__c;
    }

    // Helper to format email body
	@TestVisible
    private static String formatBody(Account acc) {
        return '<p>New account has been assigned to your territory:</p>' +
               '<ul>' +
               '<li> <b> Name: </b>' + acc.Name + '</li>' +
               '<li> <b> Type: </b>' + acc.Type + '</li>' +
			   '<li> <b> Sales Region: </b>' + acc.Sales_Region__c + '</li>' +
               '<li> <b> Industry: </b>' + acc.Industry + '</li>' +
			   '<li> <b> Prospect Spend Dir: </b>' + acc.Prospect_Spend_Air__c + '</li>' +
               '</ul>';
    }
}