public with sharing class AURA_OrgInformation {
    @AuraEnabled
    public static ORG getAll() {
        ORG orgInformation = new ORG();
        orgInformation.URL = URL.getSalesforceBaseUrl().toExternalForm();
        orgInformation.instance = [select InstanceName from Organization limit 1].InstanceName;
        orgInformation.sessionAPI = 'sessionAPI';
        orgInformation.sessionVF = 'sessionVF';
        return orgInformation;
    }

    @AuraEnabled
    public static List<User> getAllUsers() {
        return [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        Username,
                        IsActive,
                        CreatedDate
                FROM User
        ];
    }

    @AuraEnabled
    public static List<AuthSession> getSession() {
        return [
                SELECT
                        LoginType,
                        SessionType,
                        SourceIp
                FROM AuthSession
                WHERE SessionType = 'API'
                OR SessionType = 'Visualforce'
        ];
    }

    @AuraEnabled
    public static List<LoginHistory> getLoginHistories(String userId) {
        return [
                SELECT
                        Id, LoginTime, LoginType
                FROM LoginHistory
                WHERE UserId =: userId
        ];
    }

    @AuraEnabled
    public static List<GroupMember> getAllGroups(String userId) {
        return [
                SELECT Id, Group.Name
                FROM GroupMember
                WHERE UserOrGroupId =: userId
        ];
    }

    @AuraEnabled
    public static List<UserLicense> getAllLicences() {
        return [
                SELECT
                        Id,
                        Name,
                        TotalLicenses,
                        UsedLicenses
                FROM UserLicense
        ];
    }

    @AuraEnabled
    public static List<ApexClass> getAllClasses() {
        return [
                SELECT
                        Id,
                        Name,
                        CreatedDate,
                        CreatedBy.Name,
                        ApiVersion
                FROM ApexClass
        ];
    }

    @AuraEnabled
    public static List<ApexPage> getAllPages() {
        return [
                SELECT
                        Id,
                        Name,
                        CreatedDate,
                        CreatedBy.Name,
                        ApiVersion
                FROM ApexPage
        ];
    }

    public class ORG {
        @AuraEnabled
        public String URL {get; set;}
        @AuraEnabled
        public String instance {get; set;}
        @AuraEnabled
        public String sessionAPI {get; set;}
        @AuraEnabled
        public String sessionVF {get; set;}

        public ORG() {

        }
    }
}