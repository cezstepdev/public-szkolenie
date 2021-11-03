List<Contract__c> contracts = [
        SELECT Id
        FROM Contract__c
        WHERE Doctor__c = 'a000900000EpjLA'
];

delete contracts;