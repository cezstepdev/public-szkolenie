List<Contract__c> contracts = new List<Contract__c>();

for(Integer i = 0; i < 50; i++) {
    contracts.add(new Contract__c(Signing_Date__c=Date.newInstance(2031,9,2), 
            Expire_Date__c=Date.newInstance(2031,10,2), 
            Doctor__c='a000900000EpjLAAAZ', 
            Hospital__c='a010900001KWKjGAAX'));
}

insert contracts;