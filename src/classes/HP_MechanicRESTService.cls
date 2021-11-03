@RestResource(urlMapping = '/HP_MechanicRESTService/*')
global class HP_MechanicRESTService {
    @HttpGet
    global static ResponseREST getMechanicsByParameters() {
        String firstName = RestContext.request.params.get('firstName');
        String lastName = RestContext.request.params.get('lastName');
        String country = RestContext.request.params.get('country');

        MechanicDTO doctorParameters = new MechanicDTO();
        doctorParameters.firstName = firstName;
        doctorParameters.lastName = lastName;
        doctorParameters.country = country;
        List<MechanicDTO> MechanicDTOS = new List<MechanicDTO>();
        List<Mechanic__c> mechanics = searchMechanics(doctorParameters);

        if (mechanics.isEmpty()) {
            return new ResponseREST('There is no records');
        }

        for (Mechanic__c mechanic : mechanics) {
            MechanicDTO mechanicDTO = new MechanicDTO(mechanic);
            MechanicDTOS.add(mechanicDTO);
        }
        return new ResponseREST('Successful get all mechanics', MechanicDTOS);
    }

    @HttpPost
    global static ResponseREST postMechanics(List<MechanicDTO> mechanicDTOS) {
        List<Mechanic__c> mechanics = new List<Mechanic__c>();
        try {
            for (MechanicDTO mechanicDTO : mechanicDTOS) {
                Mechanic__c mechanic = new Mechanic__c();
                mechanic.First_Name__c = mechanicDTO.firstName;
                mechanic.Name = mechanicDTO.lastName;
                mechanic.Country__c = mechanicDTO.country;
                mechanic.Salary__c = mechanicDTO.salary;
                mechanic.Phone__c = mechanicDTO.phone;
                mechanic.Email__c = mechanicDTO.email;
                mechanic.Avatar__c = '#';
                mechanic.ExternalSystem__c = true;
                mechanic.ExternalId__c = mechanicDTO.mechanicId;
                mechanic.Born__c = Date.newInstance(2000, 01, 01);
                mechanics.add(mechanic);
            }
            insert mechanics;
        }
        catch (Exception e) {
            return new ResponseREST(String.valueOf(e.getMessage()));
        }

        return new ResponseREST('Successful post all mechanics', getMechanicDTOFromList(mechanics));
    }

    @HttpPatch
    global static ResponseREST updateMechanics() {
        List<Mechanic__c> mechanics = new List<Mechanic__c>();
        try {
            List<MechanicDTO> MechanicDTOS = (List<MechanicDTO>) JSON.deserialize(RestContext.request.requestBody.toString(), List<MechanicDTO>.class);
            List<Id> mechanicId = new List<Id>();
            for (MechanicDTO mechanicDTO : MechanicDTOS) {
                mechanicId.add(mechanicDTO.mechanicId);
            }

            mechanics = getMechanics(mechanicId);

            if(mechanics.isEmpty()) {
                return new ResponseREST('No mechanics with such id');
            }

            Map<Id, MechanicDTO> mechanicUpdate = new Map<Id, MechanicDTO>();
            for (MechanicDTO updateMechanics : MechanicDTOS) {
                mechanicUpdate.put(updateMechanics.mechanicId, updateMechanics);
            }

            for (Mechanic__c mechanic : mechanics) {
                MechanicDTO newMechanicData = mechanicUpdate.get(mechanic.Id);
                mechanic.First_Name__c = newMechanicData.firstName != null ? newMechanicData.firstName : mechanic.First_Name__c;
                mechanic.Name = newMechanicData.lastName != null ? newMechanicData.lastName : mechanic.Name;
                mechanic.Country__c = newMechanicData.country != null ? newMechanicData.country : mechanic.Country__c;
                mechanic.Email__c = newMechanicData.email != null ? newMechanicData.email : mechanic.Email__c;
                mechanic.Phone__c = newMechanicData.phone != null ? newMechanicData.phone : mechanic.Phone__c;
                mechanic.Salary__c = newMechanicData.salary != null ? newMechanicData.salary : mechanic.Salary__c;
                if(String.isBlank(mechanic.ExternalId__c)) {
                    mechanic.ExternalId__c = newMechanicData.externalId;
                }

                if(newMechanicData.isSync == null) {
                    mechanic.IsSync__c = true;
                } else {
                    mechanic.IsSync__c = newMechanicData.isSync;
                }
            }
            update mechanics;
        } catch (Exception e) {
            return new ResponseREST(String.valueOf(e.getMessage()));
        }
        return new ResponseREST('Successful update all mechanics', getMechanicDTOFromList(mechanics));
    }

    @HttpDelete
    global static ResponseREST deleteMechanics() {
        try {
            List<MechanicDTO> mechanicId = (List<MechanicDTO>) JSON.deserialize(RestContext.request.requestBody.toString(), List<MechanicDTO>.class);

            List<Id> mechanicIds = getIds(mechanicId);
            List<Mechanic__c> mechanics = getMechanics(mechanicIds);

            if (mechanics.isEmpty()) {
                return new ResponseREST('There is no mechanics with such id');
            }
            delete mechanics;
        } catch (Exception e) {
            return new ResponseREST( String.valueOf(e.getMessage()));
        }
        return new ResponseREST('Successful delete all mechanics');
    }

    private static List<Mechanic__c> getMechanics(List<Id> mechanicIds) {
        List<Mechanic__c> mechanics = [
                SELECT Id, First_Name__c, Name, Country__c, Email__c, Phone__c, Salary__c, Born__c, ExternalId__c
                FROM Mechanic__c
                WHERE Id IN : mechanicIds
        ];
        return mechanics;
    }

    private static List<Id> getIds(List<MechanicDTO> mechanics) {
        List<Id> mechanicId = new List<Id>();
        for (MechanicDTO mechanic : mechanics) {
            mechanicId.add(mechanic.mechanicId);
        }

        return mechanicId;
    }

    private static List<MechanicDTO> getMechanicDTOFromList(List<Mechanic__c> mechanics) {
        List<MechanicDTO> MechanicDTOS = new List<MechanicDTO>();
        for (Mechanic__c mechanic : mechanics) {
            MechanicDTO mechanicDTO = new MechanicDTO();
            mechanicDTO.mechanicId = mechanic.Id;
            mechanicDTO.firstName = mechanic.First_Name__c;
            mechanicDTO.lastName = mechanic.Name;
            mechanicDTO.country = mechanic.Country__c;
            mechanicDTO.email = mechanic.Email__c;
            mechanicDTO.phone = mechanic.Phone__c;
            mechanicDTO.salary = mechanic.Salary__c;
            MechanicDTOS.add(mechanicDTO);
        }
        return MechanicDTOS;
    }

    private static List<Mechanic__c> searchMechanics (MechanicDTO mechanic) {
        List<Mechanic__c> mechanics = new List<Mechanic__c>();
        List<String> conditions = new List<String>();

        String query =
                'SELECT First_Name__c, Name, Country__c, Email__c, Salary__c, Born__c, Phone__c, ExternalId__c, IsSync__c ' +
                        'FROM Mechanic__c ';
        conditions.clear();


        if (mechanic.lastName != null && mechanic.lastName != '') {
            conditions.add('Name LIKE' + '\'%' + mechanic.lastName + '%\'');
        }
        if (mechanic.firstName != null && mechanic.firstName != '') {
            conditions.add('First_Name__c LIKE' + '\'%' + mechanic.firstName + '%\'');
        }
        if (mechanic.country != null && mechanic.country != '') {
            conditions.add('Country__c LIKE' + '\'%' + mechanic.country + '%\'');
        }

        if (conditions.size() > 0) {
            query += 'WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++) {
                query += ' AND ' + conditions[i];
            }
        }

        mechanics = Database.query(query);
        return mechanics;
    }

    global class ResponseREST {
        webService String message;
        webService List<MechanicDTO> mechanicList;

        public ResponseREST(String message){
            this.message = message;
        }

        public ResponseREST(String message, List<MechanicDTO> mechanicList){
            this.message = message;
            this.mechanicList = mechanicList;
        }
    }

    global class MechanicDTO {
        webService String mechanicId;
        webService String firstName;
        webService String lastName;
        webService String country;
        webService String phone;
        webService String email;
        webService Decimal salary;
        webService String externalId;
        webService Boolean isSync;

        global MechanicDTO(Mechanic__c mechanic) {
            this.mechanicId = mechanic.Id;
            this.firstName = mechanic.First_Name__c;
            this.lastName = mechanic.Name;
            this.country = mechanic.Country__c;
            this.phone = mechanic.Phone__c;
            this.email = mechanic.Email__c;
            this.salary = mechanic.Salary__c;
            this.externalId = mechanic.ExternalId__c;
            this.isSync = mechanic.IsSync__c;
        }
        global MechanicDTO() {
        }
    }
}