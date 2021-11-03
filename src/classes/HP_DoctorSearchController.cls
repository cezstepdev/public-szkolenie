public class HP_DoctorSearchController {
    public Integer size { get; set; }
    public List<SelectOption> paginationSizeOptions { get; set; }
    public Doctor__c doctor { get; set; }
    public List<Doctor__c> doctors { get; set; }
    public String CSV {get; set;}
    private List<String> conditions = new List<String>();

    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {
                setCon = new ApexPages.StandardSetController(doctors);
                setCon.setPageSize(size);
            }
            return setCon;
        }
        set;
    }

    public HP_DoctorSearchController () {
        doctor = new Doctor__c();
        doctors = new List<Doctor__c>();
        size = 10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('1', '1'));
        paginationSizeOptions.add(new SelectOption('2', '2'));
        paginationSizeOptions.add(new SelectOption('5', '5'));
        paginationSizeOptions.add(new SelectOption('10', '10'));
        paginationSizeOptions.add(new SelectOption('15', '15'));

        MW_MechanicSOAP.MA_MechanicSOAPService mechanicService= new MW_MechanicSOAP.MA_MechanicSOAPService();
        mechanicService.SessionHeader = new MW_MechanicSOAP.SessionHeader_element();
        mechanicService.SessionHeader.sessionId = '00D09000007z4Sw!AQUAQOt_4C4_ukoXqny.rYozJtYdP1jSzS2h2umGYpn_rs6hUFj4crXjb271jLJCaXpYWzGyXca1jrHvm2_EjisMSBPdR_12';
    }

    public List<Doctor__c> getDoctorsList () {
        return (List<Doctor__c>) setCon.getRecords();
    }

    public void searchDoctor () {
        String query = ' SELECT FirstName__c, Name,Email__c, Country__c FROM Doctor__c ';
        conditions.clear();
        conditions.add('Name LIKE' + '\'' + doctor.Name + '%\'');

        if (doctor.FirstName__c != null && doctor.FirstName__c != '') {
            conditions.add('FirstName__c LIKE' + '\'' + doctor.FirstName__c + '%\'');
        }
        if (doctor.Country__c != null && doctor.Country__c != '') {
            conditions.add('Country__c LIKE' + '\'' + doctor.Country__c + '%\'');
        }
        if (doctor.Email__c != null && doctor.Email__c != '') {
            conditions.add('Email__c LIKE' + '\'' + doctor.Email__c + '%\'');
        }

        if (conditions.size() > 0) {
            query += 'WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++) {
                query += ' AND ' + conditions[i];
            }
        }

        doctors = Database.query(query);
        setCon = new ApexPages.StandardSetController(doctors);
    }

    public PageReference refreshPageSize () {
        setCon.setPageSize(size);
        return null;
    }

    public void clear () {
        doctor = new Doctor__c();
        doctors.clear();
    }

    public PageReference exportToXLS() {
        String fileName = String.format('Contracts', new List<String>{
                String.valueOf(Datetime.now()).replaceAll(' ', '_')
        });
        PageReference page = new PageReference('/apex/HP_ContractExportXLS?fileName=' + fileName);
        page.setRedirect(false);
        return page;
    }

    public PageReference exportToCSV() {
        createCSV();
        String fileName = String.format('Contracts', new List<String>{
                String.valueOf(Datetime.now()).replaceAll(' ', '_')
        });
        PageReference page = new PageReference('/apex/HP_ContractExportCSV?fileName=' + fileName);
        page.setRedirect(false);
        return page;
    }

    private void createCSV () {
        CSV = 'First Name;' + 'Last Name;' + 'Email;' + 'Country';
        String fileRow;

        for(Doctor__c doctor : doctors){
            fileRow = '\n';
            fileRow += doctor.FirstName__c;
            fileRow += ';' + doctor.Name;
            fileRow += ';' + doctor.Email__c;
            fileRow += ';' + doctor.Country__c;
            CSV += fileRow;
        }
    }
}