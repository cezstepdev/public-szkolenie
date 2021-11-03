public class HP_DoctorCustomViewController {
    public HP_DoctorCustomViewController(ApexPages.StandardController standardController) {

    }

    @RemoteAction
    public static void removeImage(String userId) {
        Doctor__c doctor = [
                SELECT Id, FirstName__c
                FROM Doctor__c
                WHERE Id =: userId
        ];

        doctor.Profile_Picture__c = '/resource/1630670056000/profile_pic';
        Database.update(doctor);
    }
}