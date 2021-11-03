@RestResource(urlMapping = '/Doctor__c/*')
global class HP_DoctorRESTService {
    @HttpGet
    global static RESTResponse getDoctorsByParameters() {
        String body = JSONRequest();
        if(body == null || body == '') {
            return new RESTResponse( HP_DoctorSOAPServiceHelper.noRecords);
        }

        DoctorDTO doctorParameters = (DoctorDTO) JSON.deserialize(JSONRequest(), DoctorDTO.class);
        List<DoctorDTO> doctorDTOs = new List<DoctorDTO>();
        List<Doctor__c> doctors = searchDoctor(doctorParameters);

        if (doctors.isEmpty()) {
            return new RESTResponse(HP_DoctorSOAPServiceHelper.noRecords);
        }

        for (Doctor__c doctor : doctors) {
            DoctorDTO doctorDTO = new DoctorDTO(doctor);
            doctorDTOs.add(doctorDTO);
        }
        return new RESTResponse(HP_DoctorSOAPServiceHelper.success, doctorDTOs);
    }

    @HttpPost
    global static RESTResponse postDoctors(List<DoctorDTO> doctorDTOs) {
        List<Doctor__c> doctors = new List<Doctor__c>();
        try {
            for (DoctorDTO doctorDTO : doctorDTOs) {
                Doctor__c doctor = new Doctor__c();
                doctor.FirstName__c = doctorDTO.firstName;
                doctor.Name = doctorDTO.lastName;
                doctor.Email__c = doctorDTO.email;
                doctor.Phone__c = doctorDTO.phone;
                doctor.Country__c = doctorDTO.country;
                doctor.City__c = doctorDTO.city;
                doctor.Street__c = doctorDTO.street;
                doctor.Address__c = doctorDTO.address;
                doctor.Profile_Picture__c = Label.Default_Profile_Picture;
                doctors.add(doctor);
            }

            insert doctors;
        }
        catch (Exception e) {
            return new RESTResponse(setMessage(e.getMessage()));
        }

        for (Integer i = 0; i < doctors.size(); i++) {
            doctorDTOs.get(i).doctorId = doctors.get(i).Id;
        }
        return new RESTResponse( HP_DoctorSOAPServiceHelper.success, doctorDTOs);
    }

    @HttpPatch
    global static RESTResponse updateDoctor() {
        List<Doctor__c> doctors = new List<Doctor__c>();
        try {
            List<DoctorDTO> doctorDTOs = (List<DoctorDTO>) JSON.deserialize(JSONRequest(), List<DoctorDTO>.class);
            List<Id> doctorsId = new List<Id>();
            for (DoctorDTO doctorDTO : doctorDTOs) {
                doctorsId.add(doctorDTO.doctorId);
            }

            doctors = getDoctors(doctorsId);

            if(doctors.isEmpty()) {
                return new RESTResponse(HP_DoctorSOAPServiceHelper.noRecordWithId);
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
                doctor.Phone__c = newDoctorData.phone;
                doctor.City__c = newDoctorData.city;
                doctor.Street__c = newDoctorData.street;
                doctor.Address__c = newDoctorData.address;
            }

            update doctors;
        } catch (Exception e) {
            return new RESTResponse(setMessage(e.getMessage()));
        }
        return new RESTResponse(HP_DoctorSOAPServiceHelper.success, getDoctorDTOFromList(doctors));
    }

    @HttpDelete
    global static RESTResponse deleteDoctors() {
        try {
            List<DoctorDTO> doctorsId = (List<DoctorDTO>) JSON.deserialize(JSONRequest(), List<DoctorDTO>.class);

            List<Id> doctorIds = getIds(doctorsId);
            List<Doctor__c> doctors = getDoctors(doctorIds);

            if (doctors.isEmpty()) {
                return new RESTResponse(HP_DoctorSOAPServiceHelper.noRecordWithId);
            }

            for (Doctor__c doctor : doctors) {
                delete doctor;
            }
        } catch (Exception e) {
            return new RESTResponse( setMessage(e.getMessage()));
        }
        return new RESTResponse(HP_DoctorSOAPServiceHelper.success);
    }

    private static List<Doctor__c> getDoctors(List<Id> doctorIds) {
        List<Doctor__c> doctors = [
                SELECT Id, FirstName__c, Name, Country__c, Email__c, Phone__c, City__c, Street__c, Address__c
                FROM Doctor__c
                WHERE Id IN : doctorIds
        ];
        return doctors;
    }

    private static List<Id> getIds(List<DoctorDTO> doctors) {
        List<Id> doctorsId = new List<Id>();
        for (DoctorDTO doctor : doctors) {
            doctorsId.add(doctor.doctorId);
        }

        return doctorsId;
    }

    private static String setMessage(String responseMessage) {
        String message = responseMessage;
        message = responseMessage.contains('DUPLICATES_DETECTED') ? System.Label.DuplicatedMechanic : message;
        message = responseMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? System.Label.OnlyLetter : message;
        message = responseMessage.contains('INVALID_EMAIL_ADDRESS') ? System.Label.InvalidEmail : message;
        message = responseMessage.contains('ucce') ? System.Label.SuccessOperation : message;
        return message;
    }

    private static List<Id> getDoctorsIds(List<Doctor__c> doctors) {
        List<Id> ids = new List<Id>();
        for (Doctor__c doctor : doctors) {
            ids.add(doctor.Id);
        }
        return ids;
    }

    private static String JSONRequest() {
        RestRequest request = RestContext.request;
        String JSONRequestBody = request.requestBody.toString().trim();
        return JSONRequestBody;
    }

    private static List<DoctorDTO> getDoctorDTOFromList(List<Doctor__c> doctors) {
        List<DoctorDTO> doctorDTOs = new List<DoctorDTO>();
        for (Doctor__c doctor : doctors) {
            DoctorDTO doctorDTO = new DoctorDTO();
            doctorDTO.doctorId = doctor.Id;
            doctorDTO.firstName = doctor.FirstName__c;
            doctorDTO.lastName = doctor.Name;
            doctorDTO.country = doctor.Country__c;
            doctorDTO.email = doctor.Email__c;
            doctorDTO.phone = doctor.Phone__c;
            doctorDTO.city = doctorDTO.city;
            doctorDTO.street = doctor.Street__c;
            doctorDTO.address = doctor.Address__c;
            doctorDTOs.add(doctorDTO);
        }
        return doctorDTOs;
    }

    private static List<Doctor__c> searchDoctor (DoctorDTO doctor) {
        List<Doctor__c> doctors = new List<Doctor__c>();
        List<String> conditions = new List<String>();

        String query =
                'SELECT FirstName__c, Name, Country__c, Email__c, Phone__c, City__c, Street__c, Address__c ' +
                        'FROM Doctor__c ';
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

    global class RESTResponse {
        public String message {get; set;}
        public List<DoctorDTO> doctorsDTO {get; set;}

        global RESTResponse(String message) {
            this.message = message;
        }

        global RESTResponse(String message, List<DoctorDTO> doctorsDTO) {
            this.message = message;
            this.doctorsDTO = doctorsDTO;
        }
    }

    global class DoctorDTO {
        public Id doctorId {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String country {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
        public String city {get; set;}
        public String street {get; set;}
        public String address {get; set;}

        global DoctorDTO() {

        }

        global DoctorDTO(Doctor__c doctor) {
            this.doctorId = doctor.Id;
            this.firstName = doctor.FirstName__c;
            this.lastName = doctor.Name;
            this.country = doctor.Country__c;
            this.email = doctor.Email__c;
            this.phone = doctor.Phone__c;
            this.city = doctor.City__c;
            this.street = doctor.Street__c;
            this.address = doctor.Address__c;
        }
    }
}