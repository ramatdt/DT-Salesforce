@isTest
public class TravelVolumeTriggerHandlerTest {

    @isTest
    static void testNormalizeReportedMonth_AllFormats() {
		Account acc = new Account(Name = 'Test Account', Region__c = 'Canada West');
        insert acc;

        List<Travel_Volume__c> tvList = new List<Travel_Volume__c>{
            new Travel_Volume__c(Reported_Month__c = 'January', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = 'feb', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = 'MAR', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = '4', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = '05', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = 'JUNE', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = 'jul', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = 'August', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = 'sep', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = '10', Account__c = acc.Id),
            new Travel_Volume__c(Reported_Month__c = 'november', Account__c = acc.Id)
		};

        insert tvList;

        List<Travel_Volume__c> insertedTVs = [
            SELECT Id, Reported_Month__c
            FROM Travel_Volume__c
            WHERE Id IN :tvList
            ORDER BY CreatedDate ASC
        ];

        List<String> expected = new List<String>{
            '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'
        };

        for (Integer i = 0; i < insertedTVs.size(); i++) {
            System.assertEquals(expected[i], insertedTVs[i].Reported_Month__c,
                'Mismatch at index ' + i + ': Expected ' + expected[i] +
                ', Found ' + insertedTVs[i].Reported_Month__c);
        }
    }

    @isTest
    static void testNormalizeReportedMonth_NullOrInvalid() {
		Account acc = new Account(Name = 'Test Account', Region__c = 'Canada West');
        insert acc;

        Travel_Volume__c tv1 = new Travel_Volume__c(Account__c = acc.Id); // Null month
        Travel_Volume__c tv2 = new Travel_Volume__c(Account__c = acc.Id, Reported_Month__c = 'NotAMonth');

        insert new List<Travel_Volume__c>{ tv1, tv2 };

        List<Travel_Volume__c> results = [
            SELECT Id, Reported_Month__c
            FROM Travel_Volume__c
            WHERE Id IN :new List<Id>{ tv1.Id, tv2.Id }
        ];
    }
}