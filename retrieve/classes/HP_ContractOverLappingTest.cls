@IsTest
private class HP_ContractOverLappingTest {
    @TestSetup
    static void setup() {
        insert new Doctor__c(Name='Test',FirstName__c='Test', Phone__c='1102');
        insert new Hospital__c(Name='Test', City__c='Test');
    }
    @isTest
    static void shouldInsertContracts () {
        Doctor__c doctor = [SELECT Id FROM Doctor__c];
        Hospital__c hospital = [SELECT Id FROM Hospital__c];
        List<TimeWrapper> timeWrappers = new List<TimeWrapper>{
                new TimeWrapper(Date.today().addDays(-10), Date.today().addDays(0)),
                new TimeWrapper(Date.today().addDays(1), Date.today().addDays(2)),
                new TimeWrapper(Date.today().addDays(3), Date.today().addDays(10))
        };
        List<Contract__c> validContracts = getContracts(timeWrappers, doctor.Id, hospital.Id);

        Test.startTest();
        try {
            insert validContracts;
        } catch (Exception e) {
            System.assert(false);
        }
        Test.stopTest();
        List<Contract__c> contracts = [SELECT Id FROM Contract__c];
        System.assertEquals(3, contracts.size());
    }

    @isTest
    static void shouldNotInsertContracts () {
        Doctor__c doctor = [SELECT Id FROM Doctor__c];
        Hospital__c hospital = [SELECT Id FROM Hospital__c];
        List<TimeWrapper> timeWrappers = new List<TimeWrapper>{
                new TimeWrapper(Date.today().addDays(-10), Date.today().addDays(10)),
                new TimeWrapper(Date.today().addDays(1), Date.today().addDays(2)),
                new TimeWrapper(Date.today().addDays(3), Date.today().addDays(10))
        };
        List<Contract__c> validContracts = getContracts(timeWrappers, doctor.Id, hospital.Id);

        Test.startTest();
        try {
            insert validContracts;
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
        List<Contract__c> contracts = [SELECT Id FROM Contract__c];
        System.assertEquals(0, contracts.size());
    }

    private static List<Contract__c> getContracts (List<TimeWrapper> timeWrappers, Id doctorId, Id hospitalId) {
        List<Contract__c> contracts = new List<Contract__c>();
        for (TimeWrapper timeWrapper : timeWrappers) {
            contracts.add(new Contract__c(
                            Doctor__c = doctorId,
                            Hospital__c = hospitalId,
                            Signing_Date__c = timeWrapper.startDate,
                            Expire_Date__c = timeWrapper.endDate));
        }
        return contracts;
    }

    private class TimeWrapper {
        public Date startDate;
        public Date endDate;

        public TimeWrapper(Date startDate, Date endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
}