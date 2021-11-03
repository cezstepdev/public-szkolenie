global class HP_OffBoardingBatch implements Database.Batchable<sObject> {

    private List<Schema.FieldSetMember> members;

    public HP_OffBoardingBatch() {
        this.members = readFieldSet('Boarding', 'Doctor__c');
    }

    global Database.QueryLocator start (Database.BatchableContext BC) {
        String queryFields = buildQueryFields();
        String query = 'SELECT ' + queryFields + ' FROM Doctor__c WHERE Id IN ' +
                '(SELECT Doctor__c FROM Contract__c WHERE Expire_Date__c = TODAY)';
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext BC, List<Doctor__c> doctors) {
        if(doctors.size() > 0) {
            Messaging.SingleEmailMessage singleEmailMessage = onBoardEmail(doctors);
            List<String> emails = new List<String>();
            List<User> users = [
                    select email
                    from user
                    where id in
                    (select userorgroupid from groupmember where group.name = 'Boarding')];
            for (User user : users) {
                emails.add(user.email);
            }
            singleEmailMessage.setToAddresses(emails);
            singleEmailMessage.setSenderDisplayName('Onboarding System');
            System.debug(Messaging.sendEmail(new Messaging.SingleEmailMessage[]{singleEmailMessage}));
        }
    }

    global void finish (Database.BatchableContext BC) {
    }

    private Messaging.SingleEmailMessage onBoardEmail(List<Doctor__c> doctors) {
        EmailTemplate email = [
                SELECT Id, Subject, HtmlValue, Body, BrandTemplateId
                FROM EmailTemplate
                WHERE Name = 'Off Boarding Message'
        ];
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(email.Id, UserInfo.getUserId(), UserInfo.getUserId());
        String body = message.getHtmlBody();
        body = body.replace('</head>', putCSS());
        body = body.replace('TEST_VAR', getTableBody(doctors));
        message.setHtmlBody(body);
        message.setSubject(email.Subject);
        message.setTargetObjectId(UserInfo.getUserId());
        message.setSaveAsActivity(false);
        return message;
    }

    private String buildQueryFields() {
        String query = '';
        for (FieldSetMember member : members) {
            query += member.getFieldPath() + ', ';
        }

        return query.substring(0, query.length() - 2);
    }

    private String putCSS() {
        String CSS =
                '<style type="text/css">' +
                        '.styled-table {border-collapse: collapse;margin: 25px 0;font-size: 0.9em;font-family: sans-serif;' + '' +
                        'min-width: 400px;box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);margin:10px auto;}' +
                        '.styled-table thead tr {background-color: #009879;color: #ffffff;text-align: center;}' +
                        '.styled-table th, .styled-table td {padding: 12px 15px;}' +
                        '.styled-table tbody tr {border-bottom: 1px solid #dddddd;}' +
                        '.styled-table tbody tr:nth-of-type(even) {background-color: #f3f3f3;}' +
                        '.styled-table tbody tr:last-of-type {border-bottom: 2px solid #009879;}' +
                        'button {border-radius: 8px;background-color: #009879;border: none;padding: 4px;}' +
                        '</style></head>';
        return CSS;
    }

    private String getTableBody(List<Doctor__c> doctors) {
        String header = '';
        for (Schema.FieldSetMember member : members) {
            header += '<th class="tg-ul38">' + member.getLabel() + '</th>';
        }
        header += '<th class="tg-ul38">Profile</th>';

        String body =
                '<table class="styled-table">' +
                    '<thead>' +
                        '<tr>' +
                            header +
                        '</tr>' +
                    '</thead>' +
                    '<tbody>' +
                        getDoctorValues(doctors) +
                    '</tbody>' +
                '</table>';
        return body;
    }

    private String getDoctorValues(List<Doctor__c> doctors) {
        String values = '';
        for (Doctor__c doctor : doctors) {
            values += '<tr>';
            for (Schema.FieldSetMember member : members) {
                values += '<th class="tg-ul38">' + doctor.get(member.getFieldPath()) + '</th>';
            }
            values +=
                    '<th class="tg-ul38"><a href="' +
                    URL.getSalesforceBaseUrl().toExternalForm() + '/' +
                    doctor.Id + '"><button> Profile </button></a></th></tr>';
        }
        return values;
    }

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }
}