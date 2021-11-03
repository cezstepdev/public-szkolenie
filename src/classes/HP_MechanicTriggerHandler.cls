public with sharing class HP_MechanicTriggerHandler extends HP_TriggerHandler {
    private List<Mechanic__c> newList;
    private List<Mechanic__c> oldList;
    private Map<Id, Mechanic__c> newMap;
    private Map<Id, Mechanic__c> oldMap;

    public HP_MechanicTriggerHandler () {
        this.newList = Trigger.new;
        this.oldList = Trigger.old;
        this.newMap = (Map<Id, Mechanic__c>)Trigger.newMap;
        this.oldMap = (Map<Id, Mechanic__c>)Trigger.oldMap;
    }

    public override void afterInsert() {
        HP_MechanicRESTHandler.addMechanic(newList);
    }

    public override void beforeUpdate() {
        HP_MechanicRESTHandler.updateMechanic(newList);
    }

    public override void afterDelete() {
        HP_MechanicRESTHandler.deleteMechanic(oldMap);
    }
}