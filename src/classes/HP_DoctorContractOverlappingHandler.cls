public with sharing class HP_DoctorContractOverlappingHandler {
    public static void checkOverLapping (List<Contract__c> newContracts) {
        Set<Id> doctorIds = new Set<Id>();
        Set<Id> hospitalIds = new Set<Id>();

        getDoctorAndHospitalIdsFromNewContracts(newContracts, doctorIds, hospitalIds);
        List<Contract__c> oldContracts = getExistingContractsForDoctorAndHospital(doctorIds, hospitalIds);
        Map<Id, Map<Id, List<Contract__c>>> oldContractsByDoctorAndHospitalId = getContractsByHospitalAndDoctorId(oldContracts);
        Map<Id, Map<Id, List<Contract__c>>> newContractsByDoctorAndHospitalId = getContractsByHospitalAndDoctorId(newContracts);

        checkContractsDates(newContracts, oldContractsByDoctorAndHospitalId);
        checkContractsDates(newContracts, newContractsByDoctorAndHospitalId);
    }

    private static void getDoctorAndHospitalIdsFromNewContracts (List<Contract__c> newContracts, Set<Id> doctorIds, Set<Id> hospitalIds) {
        if (newContracts == null || newContracts.isEmpty()) {
            return;
        }
        for (Contract__c contract : newContracts) {
            doctorIds.add(contract.Doctor__c);
            hospitalIds.add(contract.Hospital__c);
        }
    }

    private static Boolean isDateOverlapped (Contract__c newContract, Contract__c oldContract) {
        if ((newContract.Signing_Date__c >= oldContract.Signing_Date__c && newContract.Signing_Date__c <= oldContract.Expire_Date__c) ||
            (newContract.Expire_Date__c >= oldContract.Signing_Date__c && newContract.Expire_Date__c <= oldContract.Expire_Date__c) ||
            (newContract.Signing_Date__c <= oldContract.Signing_Date__c && newContract.Expire_Date__c >= oldContract.Expire_Date__c)) {
            return true;
        }
        return false;
    }

    private static List<Contract__c> getExistingContractsForDoctorAndHospital (Set<Id> doctorsIds, Set<Id> hospitalIds) {
        return [
                SELECT Id, Signing_Date__c, Expire_Date__c, Doctor__r.Id, Hospital__c
                FROM Contract__c
                WHERE Doctor__c IN :doctorsIds
                AND Hospital__c IN :hospitalIds
        ];
    }

    private static Map<Id, Map<Id, List<Contract__c>>> getContractsByHospitalAndDoctorId (List<Contract__c> contracts) {
        if (contracts == null || contracts.isEmpty()) {
            return new Map<Id, Map<Id, List<Contract__c>>>();
        }

        Map<Id, Map<Id, List<Contract__c>>> contractsByHospitalAndDoctorId = new Map<Id, Map<Id, List<Contract__c>>>();

        for (Contract__c contract : contracts) {
            if (!contractsByHospitalAndDoctorId.containsKey(contract.Doctor__c)) {
                contractsByHospitalAndDoctorId.put(contract.Doctor__c, new Map<Id, List<Contract__c>>());
            }
            if (!contractsByHospitalAndDoctorId.get(contract.Doctor__c).containsKey(contract.Hospital__c)) {
                contractsByHospitalAndDoctorId.get(contract.Doctor__c).put(contract.Hospital__c, new List<Contract__c>());
            }
            contractsByHospitalAndDoctorId.get(contract.Doctor__c).get(contract.Hospital__c).add(contract);
        }
        return contractsByHospitalAndDoctorId;
    }

    private static void checkContractsDates (List<Contract__c> contractListToCheck, Map<Id, Map<Id,
            List<Contract__c>>> contractsByHospitalAndDoctorId) {
        if (contractListToCheck == null || contractListToCheck.isEmpty() ||
                contractsByHospitalAndDoctorId == null || contractsByHospitalAndDoctorId.isEmpty()) {
            return;
        }
        String prefix =  System.Label.ErrorPrefix + '<br/>';
        String error = '';
        for (Contract__c contractToCheck : contractListToCheck) {
            if (contractsByHospitalAndDoctorId.containsKey(contractToCheck.Doctor__c) &&
                    contractsByHospitalAndDoctorId
                            .get(contractToCheck.Doctor__c)
                            .containsKey(contractToCheck.Hospital__c)) {

                List<Contract__c> contractByDoctorAndHospitalId = contractsByHospitalAndDoctorId
                        .get(contractToCheck.Doctor__c)
                        .get(contractToCheck.Hospital__c);

                for (Contract__c contract : contractByDoctorAndHospitalId) {
                    if (contractToCheck !== contract && isDateOverlapped(contractToCheck, contract)) {
                        if(contractToCheck.Id != contract.Id || (contract.Id == null && contractToCheck.Id == null)) {
                            error += 
                                    contract.Signing_Date__c.year() + '-' + contract.Signing_Date__c.month() + '-' +
                                    contract.Signing_Date__c.day()
                                    + ' ' + System.Label.To + ' ' +
                                    contract.Signing_Date__c.year() + '-' + contract.Signing_Date__c.month() + '-' +
                                    contract.Signing_Date__c.day() + '<br/>' + '\r\n';
                        }
                    }
                }
            }
            if (String.isNotEmpty(error)) {
                contractToCheck.addError(prefix + error, false);
            }
        }
    }
}