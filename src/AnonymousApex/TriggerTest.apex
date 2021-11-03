List<Contract__c> oldRentContracts = [
        SELECT Id, Signing_Date__c, Expire_Date__c, Doctor__r.Id, Doctor__r.Name
        FROM Contract__c
        WHERE Doctor__r.Id IN ('a000900000EpmhXAAR', 'a000900000EpjLAAAZ')
];

for(Contract__c contract : oldRentContracts) {
    System.debug(contract.Doctor__r.Id + ' ' + contract.Doctor__r.Name + ' ' + contract.Signing_Date__c + ' ' + contract.Expire_Date__c);
}