public with sharing class HP_MultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public HP_MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        System.debug(req);
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
            throw new MyCustomException('HTTP callout not supported for test methods');
        }
    }

    class MyCustomException extends Exception {}
}