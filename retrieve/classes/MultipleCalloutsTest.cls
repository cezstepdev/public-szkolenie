@isTest
public class MultipleCalloutsTest{
    public static testmethod void testAcctsAndContactsCallout() {

        SingleRequestMock fakeAccountResp = new SingleRequestMock(200,
                                                         'Complete',
                                                         '[{"Name": "sForceTest1"}]',
                                                         null);

        SingleRequestMock fakeContactsResp = new SingleRequestMock(200,
                                                  'Complete',
                                                  '[{"LastName": "Test Last Name"}]',
                                                   null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('http://api.example.com/accounts',fakeAccountResp);
        endpoint2TestResp.put('http://api.example.com/contacts',fakeContactsResp);

        HttpCalloutMock multiCalloutMock =
            	                   new MultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        //ProcessAccountsContacts.processAccountsContacts();
        //System.assertEquals(/*check for expected results here...*/);
    }
}