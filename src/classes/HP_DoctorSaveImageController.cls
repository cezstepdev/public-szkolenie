public class HP_DoctorSaveImageController {
    @RemoteAction
    public static Id saveImage(String name, String contentType, String data, String userId) {
        Document d = new Document(Name=name, FolderId=UserInfo.getUserId(), contentType=contentType, Body=EncodingUtil.base64Decode(data));
        Database.insert(d, true);
        saveProfilePic(d.id, userId);
        return d.id;
    }

    private static void saveProfilePic(String documentId, String userId) {
        Doctor__c doctor = [
                SELECT Id, FirstName__c
                FROM Doctor__c
                WHERE Id =: userId
        ];

        doctor.Profile_Picture__c = '/servlet/servlet.FileDownload?file=' + documentId;
        Database.update(doctor);
    }
}