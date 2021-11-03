trigger HP_MechanicTrigger on Mechanic__c (before insert, before update, before delete, after insert, after update, after delete) {
    new HP_MechanicTriggerHandler().run();
}