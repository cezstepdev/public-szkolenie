public with sharing class HP_MechanicRESTHandler {

    public static void addMechanic(List<Mechanic__c> newList) {
        List<HP_MechanicRESTService.MechanicDTO> mechanicDTOS = new List<HP_MechanicRESTService.MechanicDTO>();
        List<HP_MechanicRESTService.MechanicDTO> updateMechanicDTOS = new List<HP_MechanicRESTService.MechanicDTO>();
        HP_MechanicRESTService.MechanicDTO mechanicDTO;

        for (Mechanic__c mechanic : newList) {
            mechanicDTO = new HP_MechanicRESTService.MechanicDTO();
            if(String.isEmpty(mechanic.ExternalId__c)) {
                mechanicDTO.mechanicId = mechanic.Id;
                mechanicDTO.firstName = mechanic.First_Name__c;
                mechanicDTO.lastName = mechanic.Name;
                mechanicDTO.country = mechanic.Country__c;
                mechanicDTO.phone = mechanic.Phone__c;
                mechanicDTO.email = mechanic.Email__c;
                mechanicDTO.salary = mechanic.Salary__c;
                mechanicDTO.isSync = false;
                mechanicDTOS.add(mechanicDTO);
            } else {
                mechanicDTO.mechanicId = mechanic.ExternalId__c;
                mechanicDTO.externalId = mechanic.Id;
                mechanicDTO.isSync = false;
                updateMechanicDTOS.add(mechanicDTO);
            }
        }
        if(mechanicDTOS != null && !mechanicDTOS.isEmpty()) {
            System.enqueueJob(new AsyncCallouts(mechanicDTOS, 'post'));
        }
        if(updateMechanicDTOS != null && !updateMechanicDTOS.isEmpty()) {
            System.enqueueJob(new AsyncCallouts(updateMechanicDTOS, 'update'));
        }
    }

    public static void updateMechanic (List<Mechanic__c> newMechanic) {
        List<HP_MechanicRESTService.MechanicDTO> mechanicDTOS = new List<HP_MechanicRESTService.MechanicDTO>();
        HP_MechanicRESTService.MechanicDTO mechanicDTO;

        for (Mechanic__c mechanic : newMechanic) {
            mechanicDTO = new HP_MechanicRESTService.MechanicDTO();
            if(mechanic.IsSync__c) {
                mechanicDTO.mechanicId = mechanic.ExternalId__c;
                mechanicDTO.firstName = mechanic.First_Name__c;
                mechanicDTO.lastName = mechanic.Name;
                mechanicDTO.country = mechanic.Country__c;
                mechanicDTO.email = mechanic.Email__c;
                mechanicDTO.phone = mechanic.Phone__c;
                mechanicDTO.salary = mechanic.Salary__c;
                mechanicDTO.externalId = mechanic.ExternalId__c;
                mechanicDTO.isSync = false;
                mechanicDTOS.add(mechanicDTO);
            }
            if (!String.isEmpty(mechanic.ExternalId__c)) {
                mechanic.IsSync__c = true;
            }
        }
        if(mechanicDTOS != null && !mechanicDTOS.isEmpty()) {
            System.enqueueJob(new AsyncCallouts(mechanicDTOS, 'update'));
        }
    }

    public static void deleteMechanic (Map<Id, Mechanic__c> oldMap) {
        List<HP_MechanicRESTService.MechanicDTO> mechanicDTOS = new List<HP_MechanicRESTService.MechanicDTO>();
        HP_MechanicRESTService.MechanicDTO mechanicDTO;

        for(Mechanic__c mechanic : oldMap.values()) {
            mechanicDTO = new HP_MechanicRESTService.MechanicDTO();
            mechanicDTO.mechanicId = mechanic.ExternalId__c;
            mechanicDTOS.add(mechanicDTO);
        }

        if(mechanicDTOS != null && !mechanicDTOS.isEmpty()) {
            System.enqueueJob(new AsyncCallouts(mechanicDTOS, 'delete'));
        }
    }
}