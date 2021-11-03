public with sharing class HP_ContractTriggerHandler extends HP_TriggerHandler {
    private List<Contract__c> newList;
    private List<Contract__c> oldList;
    private Map<Id, Contract__c> newMap;
    private Map<Id, Contract__c> oldMap;

    public HP_ContractTriggerHandler () {
        this.newList = Trigger.new;
        this.oldList = Trigger.old;
        this.newMap = (Map<Id, Contract__c>)Trigger.newMap;
        this.oldMap = (Map<Id, Contract__c>)Trigger.oldMap;
    }

    public override void beforeInsert() {
        HP_DoctorContractOverlappingHandler.checkOverLapping(newList);
    }

    /*public override void afterUpdate() {
        HP_DoctorContractOverlappingHandler.checkOverLapping(newList);
    }*/
}