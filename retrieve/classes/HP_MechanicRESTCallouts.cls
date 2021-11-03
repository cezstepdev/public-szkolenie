public with sharing class HP_MechanicRESTCallouts {

    public static HP_MechanicRESTService.ResponseREST login () {
        String accessToken;
        if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
            return new HP_MechanicRESTService.ResponseREST(System.Label.Callout_Limit);
        } else {
            String username = SOAPCredential__c.getValues('PawelOrg') ?.Username__c;
            String key = SOAPCredential__c.getValues('PawelOrg') ?.Password__c;
            String token = SOAPCredential__c.getValues('PawelOrg') ?.Token__c;
            String password = key + token;
            String endpoint = RESTCredential__c.getValues('PawelOrg') ?.Endpoint__c;
            String client_id = RESTCredential__c.getValues('PawelOrg') ?.ClientId__c;
            String client_secret = RESTCredential__c.getValues('PawelOrg') ?.ClientSecret__c;

            String requestBody =
                    'grant_type=password&client_id=' + client_id +
                    '&client_secret=' + client_secret +
                    '&username=' + username +
                    '&password=' + password;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setBody(requestBody);
            request.setMethod('POST');
            request.setEndpoint(endpoint);

            try {
                HttpResponse res = http.send(request);
                System.debug('res: ' + res.getBody());
                OAuth2 objAuthenticationInfo = (OAuth2) JSON.deserialize(res.getBody(), OAuth2.class);
                accessToken = objAuthenticationInfo.access_token;
                Cache.Org.put('local.TokenCache.accessToken', accessToken);
            } catch (exception e) {
                return new HP_MechanicRESTService.ResponseREST(e.getMessage());
            }
        }
        return null;
    }

    public static HP_MechanicRESTService.ResponseREST getMechanics (HP_MechanicRESTService.MechanicDTO mechanicDTO) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + Cache.Org.getPartition('local.TokenCache').get('accessToken'));
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(buildEndpoint(mechanicDTO));
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return (HP_MechanicRESTService.ResponseREST) JSON.deserialize(response.getBody(), HP_MechanicRESTService.ResponseREST.class);
    }

    public static HP_MechanicRESTService.ResponseREST postMechanics (List<HP_MechanicRESTService.MechanicDTO> mechanicDTO) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + Cache.Org.getPartition('local.TokenCache').get('accessToken'));
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(RESTCredential__c.getValues('PawelOrg') ?.Service_Endpoint__c);
        request.setMethod('POST');
        request.setBody('{"mechanicDTOS":' + JSON.serialize(mechanicDTO) + '}');
        HttpResponse response = http.send(request);
        return (HP_MechanicRESTService.ResponseREST) JSON.deserialize(response.getBody(), HP_MechanicRESTService.ResponseREST.class);
    }

    public static HP_MechanicRESTService.ResponseREST deleteMechanics (List<HP_MechanicRESTService.MechanicDTO> mechanicsDTO) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + Cache.Org.getPartition('local.TokenCache').get('accessToken'));
        request.setEndpoint(RESTCredential__c.getValues('PawelOrg') ?.Service_Endpoint__c);
        request.setMethod('DELETE');
        request.setBody(JSON.serialize(mechanicsDTO));
        HttpResponse response = http.send(request);
        return (HP_MechanicRESTService.ResponseREST) JSON.deserialize(response.getBody(), HP_MechanicRESTService.ResponseREST.class);
    }

    public static HP_MechanicRESTService.ResponseREST updateMechanics (List<HP_MechanicRESTService.MechanicDTO> mechanicsDTO) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + Cache.Org.getPartition('local.TokenCache').get('accessToken'));
        request.setEndpoint(RESTCredential__c.getValues('PawelOrg') ?.Service_Endpoint__c);
        request.setMethod('PATCH');
        request.setBody(JSON.serialize(mechanicsDTO));
        HttpResponse response = http.send(request);
        return (HP_MechanicRESTService.ResponseREST) JSON.deserialize(response.getBody(), HP_MechanicRESTService.ResponseREST.class);
    }

    private static String buildEndpoint(HP_MechanicRESTService.MechanicDTO mechanicDTO) {
        String endpoint = RESTCredential__c.getValues('PawelOrg') ?.Service_Endpoint__c + '?';
        if(mechanicDTO.firstName != null) {
            endpoint += 'firstName=' + mechanicDTO.firstName + '&';
        }
        if(mechanicDTO.lastName != null) {
            endpoint += 'lastName=' + mechanicDTO.lastName + '&';
        }
        if(mechanicDTO.country != null) {
            endpoint += 'country=' + mechanicDTO.country;
        }

        return endpoint;
    }

    public class OAuth2 {
        public String access_token { get; set; }
    }
}