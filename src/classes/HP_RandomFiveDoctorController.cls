public class HP_RandomFiveDoctorController {
    public List<Doctor__c> doctors { get; set; }

    public HP_RandomFiveDoctorController () {
        doctors = new List<Doctor__c>();
        getDoctorsList();
    }

    private void getDoctorsList () {
        Integer count = [
                SELECT COUNT()
                FROM Doctor__c
        ];

        if(count > 4) {
            Integer offset = Integer.valueof((Math.random() * (count - 5)));
            doctors = [
                    SELECT FirstName__c, Name
                    FROM Doctor__c
                    LIMIT 5
                    OFFSET :offset
            ];
        }
    }
}