public with sharing class AURA_SearchFormController {
    @AuraEnabled
    public static List<Account> getAll(String name) {
        String condition = '%' + name + '%';
        List<Account> accounts = [
                SELECT
                        Id,
                        Name,
                        ShippingCountry,
                        AccountNumber,
                        Phone, Website,
                        BillingCountry, BillingCity, BillingStreet, BillingPostalCode,
                        Longitude__c, Latitude__c
                FROM Account
                WHERE Account.Name
                        LIKE :condition];

        return accounts;
    }
}