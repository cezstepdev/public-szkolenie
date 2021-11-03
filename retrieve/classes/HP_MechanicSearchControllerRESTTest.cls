@IsTest
private class HP_MechanicSearchControllerRESTTest {

    @IsTest
    private static void shouldReturnSearchedMechanicWhenExist() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock = createGetMock();
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        controller.mechanicFields.First_Name__c = 'k';
        controller.mechanicFields.Name = 'k';
        controller.mechanicFields.Nation__c = 'p';
        insertMyMechanic();

        Test.startTest();
        controller.searchMechanic();
        Test.stopTest();

        System.assertEquals('Kuba', controller.mechanics.get(0).First_Name__c);
    }

    @IsTest
    private static void shouldAddMechanicWhenDataIsCorrect() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock =
                createMock('{"message": "Successful post all mechanics", "mechanicList": [{"firstName": "Kuba"}]}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        HP_MechanicRESTService.MechanicDTO mechanic = createMechanicDTO();
        controller.mechanic.First_Name__c= mechanic.firstName;
        controller.mechanic.Name = mechanic.lastName;

        Test.startTest();
        controller.saveMechanic();
        Test.stopTest();

        System.assertEquals('Kuba', controller.response.mechanicList.get(0).firstName);
    }

    @IsTest
    private static void shouldNotAddMechanicWhenSessionExpired() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock =
                createMock('{"message": "INVALID_SESSION_ID"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();

        Test.startTest();
        controller.saveMechanic();
        Test.stopTest();

        System.assertEquals(null, controller.response.mechanicList);
    }

    @IsTest
    private static void shouldNotGetMechanicWhenSessionExpired() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock =
                createMock('{"message": "INVALID_SESSION_ID"}', 'end?');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();

        Test.startTest();
        controller.searchMechanic();
        Test.stopTest();

        System.assertEquals(null, controller.response.mechanicList);
    }

    @IsTest
    private static void shouldNotUpdateMechanicWhenSessionExpired() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock =
                createMock('{"message": "INVALID_SESSION_ID"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        controller.mechanic.ExternalSystem__c = true;

        Test.startTest();
        controller.updateMechanic();
        Test.stopTest();

        System.assertEquals(null, controller.response.mechanicList);
    }

    @IsTest
    private static void shouldNotDeleteMechanicWhenSessionExpired() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock =
                createMock('{"message": "INVALID_SESSION_ID"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        mechanic.ExternalSystem__c = true;
        controller.mechanic = mechanic;
        controller.mechanicId = 'xxx';
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.deleteMechanic();
        Test.stopTest();

        System.assertEquals(null, controller.response.mechanicList);
    }

    @IsTest
    private static  void shouldUpdateMechanicWhenIsExternal() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock =
                createMock('{"message": "Successful update all mechanics", "mechanicList": [{"firstName": "Kuba"}]}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        mechanic.ExternalSystem__c = true;
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);
        controller.setMechanicProperties();

        Test.startTest();
        controller.updateMechanic();
        Test.stopTest();

        System.assertEquals('Kuba', controller.response.mechanicList.get(0).firstName);
    }

    @IsTest
    private static  void shouldNotUpdateMechanicWhenIsInternal() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock =
                createMock('{"message": "error"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        mechanic.MySystem__c = true;
        controller.mechanic = mechanic;
        controller.mechanicId = insertMyMechanic();

        Test.startTest();
        controller.updateMechanic();
        Test.stopTest();

        System.assertEquals('error', controller.messageType);
    }

    @IsTest
    private static  void shouldDeleteMechanicWhenIsExternal() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock =
                createMock('{"message": "Successful delete all mechanics"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        mechanic.ExternalSystem__c = true;
        controller.mechanic = mechanic;
        controller.mechanicId = 'xxx';
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.deleteMechanic();
        Test.stopTest();

        System.assertEquals(null, controller.response.mechanicList);
    }

    @IsTest
    private static void shouldClearMechanicsWhenIsInList() {
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.clear();
        Test.stopTest();

        System.assertEquals(0, controller.mechanics.size());
    }

    @IsTest
    private static void firstPageTestWhenMechanicsExist() {
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.firstPage();
        Test.stopTest();

        System.assertEquals(mechanic.First_Name__c, controller.mechanicList[0].First_Name__c);
    }

    @IsTest
    private static void prevPageTestWhenMechanicExist() {
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.previousPage();
        Test.stopTest();

        System.assertEquals(mechanic.First_Name__c, controller.mechanicList[0].First_Name__c);
    }

    @IsTest
    private static void nextPageTestWhenIsMoreThanOneMechanic() {
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        controller.mechanics.add(mechanic);
        controller.mechanics.add(mechanic);
        controller.size = 1;

        Test.startTest();
        controller.nextPage();
        Test.stopTest();

        System.assertEquals(mechanic.First_Name__c, controller.mechanicList[0].First_Name__c);
    }

    @IsTest
    private static void lastPageTestWhenIsMoreThanOneMechanic() {
        HP_MechanicSearchControllerREST controller = new HP_MechanicSearchControllerREST();
        Mechanic__c mechanic = createMechanic();
        controller.mechanics.add(mechanic);
        controller.mechanics.add(mechanic);
        controller.size = 1;

        Test.startTest();
        controller.lastPage();
        Test.stopTest();

        System.assertEquals(mechanic.First_Name__c, controller.mechanicList[0].First_Name__c);
    }

    private static HttpCalloutMock createGetMock() {
        HP_RequestMock loginResponse = new HP_RequestMock(200,
                'Complete',
                '{"access_token": "00u"}',
                null);

        HP_RequestMock postResponse = new HP_RequestMock(200,
                'Complete',
                '{"message": "Successful post all mechanics", "mechanicList": [{"firstName": "Kuba"}]}',
                null);

        HP_RequestMock searchResponse = new HP_RequestMock(
                200,
                'Complete',
                '{"message": "Successful get all mechanics", "mechanicList": [{"firstName": "Kuba"}]}',
                null);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('end', loginResponse);
        endpoint2TestResp.put('end', postResponse);
        endpoint2TestResp.put('end?firstName=k&lastName=k&country=p', searchResponse);
        return new HP_MultiRequestMock(endpoint2TestResp);
    }

    private static HttpCalloutMock createMock(String message, String endpoint) {
        HP_RequestMock response = new HP_RequestMock(
                200,
                'Complete',
                message,
                null);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(endpoint, response);
        return new HP_MultiRequestMock(endpoint2TestResp);
    }

    private static HP_MechanicRESTService.MechanicDTO createMechanicDTO() {
        HP_MechanicRESTService.MechanicDTO mechanic = new HP_MechanicRESTService.MechanicDTO();
        mechanic.firstName = UtilsMethods.generateRandomString(4);
        mechanic.lastName = UtilsMethods.generateRandomString(4);
        return mechanic;
    }

    private static Mechanic__c createMechanic() {
        Mechanic__c mechanic = new Mechanic__c();
        mechanic.First_Name__c = UtilsMethods.generateRandomString(4);
        mechanic.Name = UtilsMethods.generateRandomString(4);
        mechanic.SearchId__c = 'xxx';
        return mechanic;
    }

    private static void insertCustomSettings() {
        RESTCredential__c credential = new RESTCredential__c();
        credential.Name = 'PawelOrg';
        credential.Endpoint__c = 'end';
        credential.ClientId__c = 'a';
        credential.ClientSecret__c = 'a';
        credential.Service_Endpoint__c = 'end';
        insert credential;
    }

    private static Id insertMyMechanic() {
        Mechanic__c mechanic = new Mechanic__c();
        mechanic.First_Name__c = 'k';
        mechanic.Name = 'k';
        mechanic.Nation__c = 'Poland';
        insert mechanic;
        return mechanic.Id;
    }
}