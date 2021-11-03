trigger HP_DoctorContractOverlappingTrigger on Contract__c (before insert, before update, before delete, after undelete, after insert, after update, after delete) {
    new HP_ContractTriggerHandler().run();
}