public class HP_DoctorImportController {

    public Blob csvFileBody{get;set;}
    public List<Doctor__c> doctorList {get;set;}
    public List<DoctorWrapperImport> doctorsWrappers {get; set;}
    public Boolean disable {get; set;}
    public Boolean isImport {get; set;}
    public String csvAsString{get;set;}
    private String[] csvFileLines{get;set;}

    public HP_DoctorImportController(){
        csvFileLines = new String[]{};
        doctorList = New List<Doctor__c>();
        doctorsWrappers = new List<HP_DoctorImportController.DoctorWrapperImport>();
        disable = true;
        isImport = false;
    }

    public void openCSV(){
        try {
            clear();
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n');
            System.debug('test ' + csvFileBody);
            for(Integer i=1;i<csvFileLines.size();i++){
                Doctor__c doctor = new Doctor__c();
                string[] csvRecordData = csvFileLines[i].split(';');
                doctor.FirstName__c = csvRecordData[0] ;
                doctor.Name = csvRecordData[1];
                doctor.Email__c = csvRecordData[2];
                doctor.Country__c = csvRecordData[3];
                doctorList.add(doctor);
                doctorsWrappers.add(new DoctorWrapperImport(doctor));
            }
            csvFileBody = null;
            disable = false;
        }
        catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,
                    'Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }
    }

    public void uncheckAll() {
        for (DoctorWrapperImport record : doctorsWrappers) {
            record.selected = false;
        }
    }

    public void checkAll() {
        for (DoctorWrapperImport record : doctorsWrappers) {
            record.selected = true;
        }
    }

    public void reverseSelected() {
        List<DoctorWrapperImport> selected = getSelected();
        List<DoctorWrapperImport> notSelected = getNotSelected();

        for (DoctorWrapperImport record : selected) {
            record.selected = false;
        }
        for (DoctorWrapperImport record : notSelected) {
            record.selected = true;
        }
    }

    public void clear() {
        doctorList.clear();
        doctorsWrappers.clear();
        disable = true;
        System.debug(doctorList.size());
    }

    public void importRecords() {
        List<DoctorWrapperImport> doctorsToImport = getSelected();
        if(doctorsToImport.size() < 1) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,
                    'No record selected');
            ApexPages.addMessage(errorMessage);
            return;
        }
        clearNotImportingStatus();
        uncheckAll();
        for (DoctorWrapperImport record : doctorsToImport) {
            System.debug(record.doctor.Name + ' ' + record.selected);
            Database.SaveResult result = Database.insert(record.doctor, false);
            if (result.isSuccess()) {
                record.status = 'Imported';
                record.URL = 'https://britenet67-dev-ed--c.visualforce.com/' + result.getId();
            }
            else {
                for(Database.Error error : result.getErrors()) {
                    List<String> errorConflictFields = error.getFields();
                    record.status = error.getMessage();
                }
            }
        }
    }

    private void clearNotImportingStatus() {
        for (DoctorWrapperImport record : doctorsWrappers) {
            record.status = '';
            record.URL = '';
        }
    }

    private List<DoctorWrapperImport> getSelected() {
        List<DoctorWrapperImport> selectedDoctors = new List<DoctorWrapperImport>();
        for (DoctorWrapperImport record : doctorsWrappers) {
            if(record.selected) {
                selectedDoctors.add(record);
            }
        }
        return selectedDoctors;
    }

    private List<DoctorWrapperImport> getNotSelected() {
        List<DoctorWrapperImport> notSelectedDoctors = new List<DoctorWrapperImport>();
        for (DoctorWrapperImport record : doctorsWrappers) {
            if(!record.selected) {
                notSelectedDoctors.add(record);
            }
        }
        return notSelectedDoctors;
    }

    public class DoctorWrapperImport {
        public Boolean selected {get; set;}
        public Doctor__c doctor {get; set;}
        public String status {get; set;}
        public String URL {get; set;}

        public DoctorWrapperImport(Doctor__c doctor) {
            this.doctor = doctor;
            this.selected = false;
            this.status = '';
            this.URL = '';
        }
    }
}