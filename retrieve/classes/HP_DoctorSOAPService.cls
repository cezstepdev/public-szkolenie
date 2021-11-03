global class HP_DoctorSOAPService {

    webService static SOAPResponse addDoctors(List<DoctorDTO> doctorDTOs) {
        List<Doctor__c> doctors = new List<Doctor__c>();
        for (DoctorDTO doctorDTO : doctorDTOs) {
            Doctor__c doctor = new Doctor__c();
            doctor.FirstName__c = doctorDTO.firstName;
            doctor.Name = doctorDTO.lastName;
            doctor.Email__c = doctorDTO.email;
            doctor.Country__c = doctorDTO.country;
            doctor.City__c = doctorDTO.city;
            doctor.Street__c = doctorDTO.street;
            doctor.Profile_Picture__c = Label.Default_Profile_Picture;
            doctors.add(doctor);
        }

        try {
            insert doctors;
        }
        catch (System.DmlException e) {
            return new SOAPResponse(e.getMessage(), null);
        }

        for (Integer i = 0; i < doctors.size(); i++) {
            doctorDTOs.get(i).doctorId = doctors.get(i).Id;
        }
        return new SOAPResponse(HP_DoctorSOAPServiceHelper.success, doctorDTOs);
    }

    webservice static SOAPResponse getDoctorsByParameters(DoctorDTO doctorParameters) {
        List<DoctorDTO> doctorDTOs = new List<DoctorDTO>();
        List<Doctor__c> doctors = searchDoctor(doctorParameters);

        if (doctors.isEmpty()) {
            return new SOAPResponse(HP_DoctorSOAPServiceHelper.noRecords, null);
        }

        for (Doctor__c doctor : doctors) {
            DoctorDTO doctorDTO = new DoctorDTO(doctor);
            doctorDTOs.add(doctorDTO);
        }
        return new SOAPResponse(HP_DoctorSOAPServiceHelper.success, doctorDTOs);
    }

    webservice static SOAPResponse getDoctors() {
        List<DoctorDTO> doctorDTOs = new List<DoctorDTO>();
        List<Doctor__c> doctors = [
                SELECT Id, FirstName__c, Name, Country__c, Email__c, Street__c, City__c
                FROM Doctor__c
        ];

        if (doctors.isEmpty()) {
            return new SOAPResponse(HP_DoctorSOAPServiceHelper.noRecords, null);
        }

        for (Doctor__c doctor : doctors) {
            DoctorDTO doctorDTO = new DoctorDTO(doctor);
            doctorDTOs.add(doctorDTO);
        }

        return new SOAPResponse(HP_DoctorSOAPServiceHelper.success, doctorDTOs);
    }

    webService static SOAPResponse updateDoctor(List<DoctorDTO> doctorDTOs) {
        List<Id> doctorsId = new List<Id>();
        for (DoctorDTO doctorDTO : doctorDTOs) {
            doctorsId.add(doctorDTO.doctorId);
        }

        List<Doctor__c> doctors = [
                SELECT Id, FirstName__c, Name, Country__c, Email__c, Street__c, City__c
                FROM Doctor__c
                WHERE Id IN : doctorsId
        ];

        if(doctors.isEmpty()) {
            return new SOAPResponse(HP_DoctorSOAPServiceHelper.noRecordWithId, null);
        }

        Map<Id, DoctorDTO> updateDoctors = new Map<Id, DoctorDTO>();
        for (DoctorDTO updateDoctor : doctorDTOs) {
            updateDoctors.put(updateDoctor.doctorId, updateDoctor);
        }

        for (Doctor__c doctor : doctors) {
            DoctorDTO newDoctorData = updateDoctors.get(doctor.Id);
            doctor.FirstName__c = newDoctorData.firstName != null ? newDoctorData.firstName : doctor.FirstName__c;
            doctor.Name = newDoctorData.lastName != null ? newDoctorData.lastName : doctor.Name;
            doctor.Country__c = newDoctorData.country;
            doctor.Email__c = newDoctorData.email;
            doctor.Street__c = newDoctorData.street;
            doctor.City__c = newDoctorData.city;
        }

        try {
            update doctors;
        } catch (Exception e) {
            return new SOAPResponse(e.getMessage(), null);
        }
        return new SOAPResponse(HP_DoctorSOAPServiceHelper.success, getDoctorDTOFromList(doctors));
    }

    webService static SOAPResponse deleteDoctors(List<Id> doctorIds) {
        List<Doctor__c> doctors = getDoctors(doctorIds);
        if (doctors.isEmpty()) {
            return new SOAPResponse(HP_DoctorSOAPServiceHelper.noRecordWithId, null);
        }

        for (Doctor__c doctor : doctors) {
            delete doctor;
        }
        return new SOAPResponse(HP_DoctorSOAPServiceHelper.success, null);
    }

    public static List<Doctor__c> getDoctors(List<Id> doctorIds) {
        List<Doctor__c> doctors = [
                SELECT Id
                FROM Doctor__c
                WHERE Id IN :doctorIds
        ];

        return doctors;
    }

    public static List<DoctorDTO> getDoctorDTOFromList(List<Doctor__c> doctors) {
        List<DoctorDTO> doctorDTOs = new List<DoctorDTO>();
        for (Doctor__c doctor : doctors) {
            DoctorDTO doctorDTO = new DoctorDTO();
            doctorDTO.doctorId = doctor.Id;
            doctorDTO.firstName = doctor.FirstName__c;
            doctorDTO.lastName = doctor.Name;
            doctorDTO.country = doctor.Country__c;
            doctorDTO.email = doctor.Email__c;
            doctorDTO.street = doctor.Street__c;
            doctorDTO.city = doctorDTO.city;
            doctorDTOs.add(doctorDTO);
        }
        return doctorDTOs;
    }

    public static List<Doctor__c> searchDoctor (DoctorDTO doctor) {
        List<Doctor__c> doctors = new List<Doctor__c>();
        List<String> conditions = new List<String>();

        String query = ' SELECT FirstName__c, Name,Email__c, Country__c, City__c, Street__c FROM Doctor__c ';
        conditions.clear();


        if (doctor.lastName != null && doctor.lastName != '') {
            conditions.add('Name LIKE' + '\'%' + doctor.lastName + '%\'');
        }
        if (doctor.firstName != null && doctor.firstName != '') {
            conditions.add('FirstName__c LIKE' + '\'%' + doctor.firstName + '%\'');
        }
        if (doctor.country != null && doctor.country != '') {
            conditions.add('Country__c LIKE' + '\'%' + doctor.country + '%\'');
        }
        if (doctor.email != null && doctor.email != '') {
            conditions.add('Email__c LIKE' + '\'%' + doctor.email + '%\'');
        }

        if (conditions.size() > 0) {
            query += 'WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++) {
                query += ' AND ' + conditions[i];
            }
        }

        doctors = Database.query(query);
        return doctors;
    }

    global class SOAPResponse {
        webService String message {get; set;}
        webService List<DoctorDTO> doctorsDTO {get; set;}

        global SOAPResponse(String message, List<DoctorDTO> doctorsDTO) {
            this.message = message;
            this.doctorsDTO = doctorsDTO;
        }
    }

    global class DoctorDTO {
        webService Id doctorId {get; set;}
        webService String firstName {get; set;}
        webService String lastName {get; set;}
        webService String country {get; set;}
        webService String email {get; set;}
        webService String city {get; set;}
        webService String street {get; set;}

        global DoctorDTO() {

        }

        global DoctorDTO(Doctor__c doctor) {
            this.doctorId = doctor.Id;
            this.firstName = doctor.FirstName__c;
            this.lastName = doctor.Name;
            this.country = doctor.Country__c;
            this.email = doctor.Email__c;
            this.city = doctor.City__c;
            this.street = doctor.Street__c;
        }
    }
}