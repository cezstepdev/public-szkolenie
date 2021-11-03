@isTest
global class HP_MechanicWebServiceMock implements WebServiceMock {

    @TestVisible
    private static Boolean isSessionInvalid {get {
        if(isSessionInvalid == null) {
            return false;
        }
        return isSessionInvalid;
    } set;}

    global void doInvoke (Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

        MW_MechanicSOAP.MechanicDTO mechanicDTO = new MW_MechanicSOAP.MechanicDTO();
        mechanicDTO.mechanicId = '1234';
        mechanicDTO.firstName = 'Name';
        mechanicDTO.lastName = 'Surname';
        mechanicDTO.country = 'PL';
        mechanicDTO.email = 'test@test.com';
        mechanicDTO.phone = '222000222';

        List<MW_MechanicSOAP.MechanicDTO> mechanicsDTO = new List<MW_MechanicSOAP.MechanicDTO>{
                mechanicDTO
        };
        MW_MechanicSOAP.SOAPResponse SOAPResponse = new MW_MechanicSOAP.SOAPResponse();

        if (requestName == 'login') {
            partnerSoapSforceCom.loginResponse_element loginResponse = new partnerSoapSforceCom.loginResponse_element();
            partnerSoapSforceCom.LoginResult loginResult = new partnerSoapSforceCom.LoginResult();
            loginResult.sessionId = 'x';
            loginResponse.result = loginResult;
            response.put('response_x', loginResponse);
            return;
        }

        if(isSessionInvalid) {
            isSessionInvalid = false;
            throw new MyException('INVALID_SESSION_ID');
        }

        if (requestName == 'getMechanics') {
            MW_MechanicSOAP.getMechanicsResponse_element responseElement = new MW_MechanicSOAP.getMechanicsResponse_element();
            responseElement.result = mechanicsDTO;
            response.put('response_x', responseElement);
        }

        if (requestName == 'postMechanicList') {
            SOAPResponse.mechanicDTO = null;
            SOAPResponse.message = 'all mechanics inserted successfully';

            MW_MechanicSOAP.postMechanicListResponse_element responseElement = new MW_MechanicSOAP.postMechanicListResponse_element();
            responseElement.result = SOAPResponse;
            response.put('response_x', responseElement);
        }

        if (requestName == 'updateMechanicList') {
            SOAPResponse.mechanicDTO = null;
            SOAPResponse.message = 'all mechanics update successfully';

            MW_MechanicSOAP.updateMechanicListResponse_element responseElement = new MW_MechanicSOAP.updateMechanicListResponse_element();
            responseElement.result = SOAPResponse;
            response.put('response_x', responseElement);
        }

        if (requestName == 'deleteMechanicList') {
            SOAPResponse.mechanicDTO = null;
            SOAPResponse.message = 'all mechanics deleted successfully';

            MW_MechanicSOAP.deleteMechanicListResponse_element responseElement = new MW_MechanicSOAP.deleteMechanicListResponse_element();
            responseElement.result = SOAPResponse;
            response.put('response_x', responseElement);
        }
    }

    public class MyException extends Exception{}
}