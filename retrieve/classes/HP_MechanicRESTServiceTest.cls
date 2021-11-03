@IsTest
private class HP_MechanicRESTServiceTest {

    @IsTest
    private static void shouldNotReturnMechanicWhenNobodyExist() {
        RestContext.request = new RestRequest();
        RestContext.request.params.put('firstName', 'a');

        Test.startTest();
        HP_MechanicRESTService.ResponseREST responseREST = HP_MechanicRESTService.getMechanicsByParameters();
        Test.stopTest();

        System.assertEquals(null, responseREST.mechanicList);
    }

    @IsTest
    private static void shouldReturnMechanicWhenExist() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock = createMock('{"message": "Successful post all mechanics"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        insertMechanic();
        RestContext.request = new RestRequest();
        RestContext.request.params.put('firstName', 'a');
        RestContext.request.params.put('lastName', 'a');
        RestContext.request.params.put('country', 'a');

        Test.startTest();
        HP_MechanicRESTService.ResponseREST responseREST = HP_MechanicRESTService.getMechanicsByParameters();
        Test.stopTest();

        System.assertEquals('a', responseREST.mechanicList.get(0).firstName);
    }

    @IsTest
    private static void shouldPostMechanicWhenDataIsCorrect() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock = createMock('{"message": "Successful post all mechanics"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        List<HP_MechanicRESTService.MechanicDTO> mechanicDTOS = new List<HP_MechanicRESTService.MechanicDTO>();
        HP_MechanicRESTService.MechanicDTO mechanicDTO = createMechanicDTO();
        mechanicDTOS.add(mechanicDTO);

        Test.startTest();
        HP_MechanicRESTService.ResponseREST responseREST = HP_MechanicRESTService.postMechanics(mechanicDTOS);
        Test.stopTest();

        System.assertEquals(mechanicDTO.firstName, responseREST.mechanicList.get(0).firstName);
    }

    @IsTest
    private static void shouldTryUpdateMechanicWhenDataIsCorrect() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock = createMock('{"message": "Successful post all mechanics"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        List<HP_MechanicRESTService.MechanicDTO> mechanicDTOS = new List<HP_MechanicRESTService.MechanicDTO>();
        HP_MechanicRESTService.MechanicDTO mechanicDTO = createMechanicDTO();
        mechanicDTO.mechanicId = 'a';
        mechanicDTOS.add(mechanicDTO);

        Test.startTest();
        HP_MechanicRESTService.ResponseREST responseREST = HP_MechanicRESTService.postMechanics(mechanicDTOS);
        Test.stopTest();

        System.assertEquals(mechanicDTO.firstName, responseREST.mechanicList.get(0).firstName);
    }

    @IsTest
    private static void shouldUpdateMechanicWhenDataIsCorrect() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock = createMock('{"message": "Successful post all mechanics"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Id id = insertMechanic();
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('[{"mechanicId": "' + id + '", "lastName": "e"}]');

        Test.startTest();
        HP_MechanicRESTService.ResponseREST responseREST = HP_MechanicRESTService.updateMechanics();
        Test.stopTest();

        System.assertEquals('e', responseREST.mechanicList.get(0).lastName);
    }

    @IsTest
    private static void shouldNotUpdateMechanicWhenDataIsIncorrect() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock = createMock('{"message": "Successful post all mechanics"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('[{"mechanicId": "random", "lastName": "e"}]');

        Test.startTest();
        HP_MechanicRESTService.ResponseREST responseREST = HP_MechanicRESTService.updateMechanics();
        Test.stopTest();

        System.assertEquals(null, responseREST.mechanicList);
    }

    @IsTest
    private static void shouldDeleteMechanicWhenExist() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock = createMock('{"message": "Successful post all mechanics"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Id id = insertMechanic();
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('[{"mechanicId": "' + id + '"}]');

        Test.startTest();
        HP_MechanicRESTService.ResponseREST responseREST = HP_MechanicRESTService.deleteMechanics();
        Test.stopTest();

        System.assertEquals(null, responseREST.mechanicList);
    }

    @IsTest
    private static void shouldNotDeleteMechanicWhenDoesntExist() {
        insertCustomSettings();
        HttpCalloutMock multiCalloutMock = createMock('{"message": "Successful post all mechanics"}', 'end');
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf('[{"mechanicId": "random"}]');

        Test.startTest();
        HP_MechanicRESTService.ResponseREST responseREST = HP_MechanicRESTService.deleteMechanics();
        Test.stopTest();

        System.assertEquals(null, responseREST.mechanicList);
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

    private static void insertCustomSettings() {
        RESTCredential__c credential = new RESTCredential__c();
        credential.Name = 'PawelOrg';
        credential.Endpoint__c = 'end';
        credential.ClientId__c = 'a';
        credential.ClientSecret__c = 'a';
        credential.Service_Endpoint__c = 'end';
        insert credential;
    }

    private static Id insertMechanic() {
        Mechanic__c mechanic = new Mechanic__c();
        mechanic.First_Name__c = 'a';
        mechanic.Name = 'a';
        mechanic.Email__c = 'a';
        mechanic.Country__c = 'a';
        insert mechanic;
        return mechanic.Id;
    }

    private static HP_MechanicRESTService.MechanicDTO createMechanicDTO() {
        HP_MechanicRESTService.MechanicDTO mechanicDTO = new HP_MechanicRESTService.MechanicDTO();
        mechanicDTO.firstName = 'a';
        mechanicDTO.lastName = 'a';
        mechanicDTO.email = 'a';
        return mechanicDTO;
    }
}