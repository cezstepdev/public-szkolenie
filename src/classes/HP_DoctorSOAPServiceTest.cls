@isTest
private class HP_DoctorSOAPServiceTest {
    
    @isTest
    private static void ShouldReturnCorrectDoctor() {
        HP_DoctorSOAPService.DoctorDTO doctorDTO = createCorrectDoctor();

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.getDoctorsByParameters(doctorDTO);
        Test.stopTest();

        System.assert(!response.doctorsDTO.isEmpty());
        System.assertEquals(doctorDTO.firstName, response.doctorsDTO[0].firstName);
    }

    @isTest
    private static void ShouldReturnCorrectMessageWhenDoctorDoesntExist() {
        HP_DoctorSOAPService.DoctorDTO doctorDTO = new HP_DoctorSOAPService.DoctorDTO();
        doctorDTO.firstName = 'h';

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.getDoctorsByParameters(doctorDTO);
        Test.stopTest();

        System.assertEquals(System.Label.NoRecords, response.message);
    }

    @isTest
    private static void ShouldReturnAllWhenExist() {
        List<HP_DoctorSOAPService.DoctorDTO> doctorDTOS = new List<HP_DoctorSOAPService.DoctorDTO>();
        HP_DoctorSOAPService.DoctorDTO doctorDTO = createCorrectDoctor();
        doctorDTOS.add(doctorDTO);

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.getDoctors();
        Test.stopTest();

        System.assertEquals(1, response.doctorsDTO.size());
    }

    @isTest
    private static void shouldAddDoctorWhenIsDataCorrect() {
        List<HP_DoctorSOAPService.DoctorDTO> doctors = new List<HP_DoctorSOAPService.DoctorDTO>();
        HP_DoctorSOAPService.DoctorDTO doctorDTO = createCorrectDoctor();
        doctorDTO.firstName = 'a';
        doctors.add(doctorDTO);

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.addDoctors(doctors);
        Test.stopTest();

        System.assertEquals(doctorDTO.firstName, response.doctorsDTO[0].firstName);
    }

    @isTest
    private static void shouldNotAddDoctorWhenDataIsInvalid() {
        List<HP_DoctorSOAPService.DoctorDTO> doctors = new List<HP_DoctorSOAPService.DoctorDTO>();
        HP_DoctorSOAPService.DoctorDTO doctorDTO = createIncorrectDoctor();
        doctors.add(doctorDTO);

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.addDoctors(doctors);
        Test.stopTest();

        System.assertEquals(null, response.doctorsDTO);
        System.assert(String.isNotEmpty(response.message));
    }

    @isTest
    private static void shouldUpdateDoctorWhenExist() {
        HP_DoctorSOAPService.DoctorDTO doctorDTO = HP_DoctorSOAPService.getDoctors().doctorsDTO[0];
        List<HP_DoctorSOAPService.DoctorDTO> doctors = new List<HP_DoctorSOAPService.DoctorDTO>();
        doctorDTO.firstName = 'd';
        doctorDTO.lastName = 'd';
        doctors.add(doctorDTO);

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.updateDoctor(doctors);
        Test.stopTest();

        System.assertEquals(doctorDTO.firstName, response.doctorsDTO[0].firstName);
    }

    @isTest
    private static void shouldNotUpdateDoctorWhenNothingToUpdate() {
        List<HP_DoctorSOAPService.DoctorDTO> doctors = new List<HP_DoctorSOAPService.DoctorDTO>();
        HP_DoctorSOAPService.DoctorDTO doctorDTO = createCorrectDoctor();
        doctors.add(doctorDTO);

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.updateDoctor(doctors);
        Test.stopTest();

        System.assertEquals(System.Label.NoRecordWithId, response.message);
    }

    @isTest
    private static void shouldDeleteDoctorWhenExist() {
        HP_DoctorSOAPService.DoctorDTO doctorDTO = HP_DoctorSOAPService.getDoctors().doctorsDTO[0];
        List<Id> doctorsId = new List<Id>();
        Id doctorId = doctorDTO.doctorId;
        doctorsId.add(doctorId);

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.deleteDoctors(doctorsId);
        Test.stopTest();

        System.assertEquals(System.Label.SuccessOperation, response.message);
    }

    @isTest
    private static void shouldNotDeleteDoctorWhoDoesntExist() {
        List<Id> doctorsId = new List<Id>();
        Id doctorId = 'a000900000Er5c6';
        doctorsId.add(doctorId);

        Test.startTest();
        HP_DoctorSOAPService.SOAPResponse response = HP_DoctorSOAPService.deleteDoctors(doctorsId);
        Test.stopTest();

        System.assertEquals(System.Label.NoRecordWithId, response.message);
    }

    private static HP_DoctorSOAPService.DoctorDTO createCorrectDoctor() {
        HP_DoctorSOAPService.DoctorDTO doctorDTO = new HP_DoctorSOAPService.DoctorDTO();
        doctorDTO.doctorId = 'a000900000Er5c6';
        doctorDTO.firstName = 'd';
        doctorDTO.lastName = 'd';
        doctorDTO.email = 'f@mail.com';
        return doctorDTO;
    }

    private static HP_DoctorSOAPService.DoctorDTO createIncorrectDoctor() {
        HP_DoctorSOAPService.DoctorDTO doctorDTO = new HP_DoctorSOAPService.DoctorDTO();
        doctorDTO.doctorId = 'a000900000Er5c6';
        doctorDTO.firstName = 'd';
        doctorDTO.lastName = 'd';
        doctorDTO.email = 'f';
        return doctorDTO;
    }

    @TestSetup
    static void makeData() {
        Doctor__c doctor = new Doctor__c();
        doctor.FirstName__c = 'd';
        doctor.Name = 'd';
        doctor.Email__c = 'f@mail.com';
        insert doctor;
    }
}