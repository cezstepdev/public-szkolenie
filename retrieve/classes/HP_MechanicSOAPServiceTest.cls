@isTest
public class HP_MechanicSOAPServiceTest {

    @IsTest
    private static void shouldReturnSearchedMechanicFromMechanicListWhenExist() {
        HP_MechanicWebServiceMock.isSessionInvalid = true;
        Test.setMock(WebServiceMock.class, new HP_MechanicWebServiceMock());
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        MW_MechanicSOAP.MechanicDTO mechanicDTO = createMechanicDTO(controller);

        Test.startTest();
        controller.searchMechanic();
        Test.stopTest();

        System.assertEquals(mechanicDTO.firstName, controller.mechanicDTOs[0].firstName);
        System.assertEquals(mechanicDTO.lastName, controller.mechanicDTOs[0].lastName);
        System.assertEquals(mechanicDTO.country, controller.mechanicDTOs[0].country);
        System.assertEquals(mechanicDTO.email, controller.mechanicDTOs[0].email);
    }
    
    @IsTest
    private static void shouldReturnCreatedMechanicWhenDataIsCorrect() {
        HP_MechanicWebServiceMock.isSessionInvalid = true;
        Test.setMock(WebServiceMock.class, new HP_MechanicWebServiceMock());
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        String message = 'all mechanics inserted successfully';
        Mechanic__c mechanic = createMechanic();
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.saveMechanic();
        Test.stopTest();

        System.assertEquals(null, controller.response.mechanicDTO);
        System.assertEquals(message, controller.response.message);
    }
    
    @IsTest
    private static void shouldReturnUpdatedMechanicFirstNameWhenSomethingToUpdate() {
        HP_MechanicWebServiceMock.isSessionInvalid = true;
        Test.setMock(WebServiceMock.class, new HP_MechanicWebServiceMock());
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        String message = 'all mechanics update successfully';
        controller.mechanic.First_Name__c = 'name';
        controller.setMechanicProperties();

        Test.startTest();
        controller.updateMechanic();
        Test.stopTest();
       
        System.assertEquals(null, controller.response.mechanicDTO);
        System.assertEquals(message, controller.response.message);
    }
    
    @IsTest
    private static void shouldReturnCorrectMessageAfterDeleteWhenMechanicExist() {
        HP_MechanicWebServiceMock.isSessionInvalid = true;
        Test.setMock(WebServiceMock.class, new HP_MechanicWebServiceMock());
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        String message = 'all mechanics deleted successfully';
        Mechanic__c mechanic = createMechanic();
        controller.mechanicId = 'xxx';
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);
        controller.setMechanicProperties();

        Test.startTest();
        controller.deleteMechanic();
        Test.stopTest();
       
        System.assertEquals(message, controller.response.message);
    }

    @IsTest
    private static void shouldClearMechanicsWhenIsInList() {
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        Mechanic__c mechanic = createMechanic();
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.clear();
        Test.stopTest();

        System.assertEquals(0, controller.mechanics.size());
    }

    @IsTest
    private static void firstPageTestWhenMechanicsExist() {
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        Mechanic__c mechanic = createMechanic();
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.firstPage();
        Test.stopTest();

        System.assertEquals(mechanic.First_Name__c, controller.mechanicList[0].First_Name__c);
    }

    @IsTest
    private static void prevPageTestWhenMechanicExist() {
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        Mechanic__c mechanic = createMechanic();
        controller.mechanic = mechanic;
        controller.mechanics.add(mechanic);

        Test.startTest();
        controller.previousPage();
        Test.stopTest();

        System.assertEquals(mechanic.First_Name__c, controller.mechanicList[0].First_Name__c);
    }

    @IsTest
    private static void nextPageTestWhenIsMoreThanOneMechanic() {
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        Mechanic__c mechanic = createMechanic();
        controller.mechanics.add(mechanic);
        controller.mechanics.add(mechanic);
        controller.size = 1;

        Test.startTest();
        controller.nextPage();
        Test.stopTest();

        System.assertEquals(mechanic.First_Name__c, controller.mechanicList[0].First_Name__c);
    }

    @IsTest
    private static void lastPageTestWhenIsMoreThanOneMechanic() {
        HP_MechanicSearchController controller = new HP_MechanicSearchController();
        Mechanic__c mechanic = createMechanic();
        controller.mechanics.add(mechanic);
        controller.mechanics.add(mechanic);
        controller.size = 1;

        Test.startTest();
        controller.lastPage();
        Test.stopTest();

        System.assertEquals(mechanic.First_Name__c, controller.mechanicList[0].First_Name__c);
    }

    private static MW_MechanicSOAP.MechanicDTO createMechanicDTO(HP_MechanicSearchController controller) {
        controller.mechanicFields.First_Name__c = 'a';
        controller.mechanicFields.Name = 'a';
        controller.mechanicFields.Nation__c = 'a';

        MW_MechanicSOAP.MechanicDTO mechanicDTO = new MW_MechanicSOAP.MechanicDTO();
        mechanicDTO.firstName = 'Name';
        mechanicDTO.lastName = 'Surname';
        mechanicDTO.country = 'PL';
        mechanicDTO.email = 'test@test.com';
        return mechanicDTO;
    }

    private static Mechanic__c createMechanic() {
        Mechanic__c mechanic = new Mechanic__c();
        mechanic.First_Name__c = 'Name';
        mechanic.Name = 'Surname';
        mechanic.Nation__c = 'USA';
        mechanic.Phone__c = '222000222';
        mechanic.Email__c = 'test@test.com';
        mechanic.ExternalId__c = 'xxx';
        return mechanic;
    }
}