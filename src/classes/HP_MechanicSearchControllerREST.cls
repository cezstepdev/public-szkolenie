public class HP_MechanicSearchControllerREST {
    public List<HP_MechanicRestService.MechanicDTO> mechanicDTOs { get; set; }

    public List<Mechanic__c> mechanicList { get; set; }
    public List<Mechanic__c> mechanics { get; set; }
    public Mechanic__c mechanic { get; set; }
    public String mechanicId { get; set; }
    public Mechanic__c mechanicFields { get; set; }
    public Mechanic__c mechanicNewValues { get; set; }
    public HP_MechanicRESTService.ResponseREST response { get; set; }
    public HP_MechanicRESTService.ResponseREST loginResponse { get; set; }

    public String errorMsg { get; set; }
    public String messageType { get; set; }

    public Integer size { get; set; }
    public List<SelectOption> paginationSizeOptions { get; set; }
    public Integer totalRecs { get; set; }
    public Integer offsetSize { get; set; }

    public HP_MechanicSearchControllerREST () {
        mechanic = new Mechanic__c();
        mechanics = new List<Mechanic__c>();
        mechanicDTOs = new List<HP_MechanicRestService.MechanicDTO>();
        mechanicFields = new Mechanic__c();
        mechanicNewValues = new Mechanic__c();

        size = 5;
        totalRecs = 0;
        offsetSize = 0;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('1', '1'));
        paginationSizeOptions.add(new SelectOption('2', '2'));
        paginationSizeOptions.add(new SelectOption('5', '5'));
        paginationSizeOptions.add(new SelectOption('10', '10'));
        paginationSizeOptions.add(new SelectOption('15', '15'));
    }

    public void searchMechanic () {
        offsetSize = 0;
        HP_MechanicRESTService.MechanicDTO searchedMechanic = new HP_MechanicRESTService.MechanicDTO();
        searchedMechanic.firstName = mechanicFields.First_Name__c;
        searchedMechanic.lastName = mechanicFields.Name;
        searchedMechanic.country = mechanicFields.Nation__c;
        if (String.isEmpty((String) Cache.Org.getPartition('local.TokenCache').get('accessToken'))) {
            loginResponse = HP_MechanicRESTCallouts.login();
        }
        response = HP_MechanicRESTCallouts.getMechanics(searchedMechanic);
        if (response.message.contains('INVALID_SESSION_ID')) {
            loginResponse = HP_MechanicRESTCallouts.login();
            response = HP_MechanicRESTCallouts.getMechanics(searchedMechanic);
        }
        mechanics = getCustomMechanic(response.mechanicList);
        getMechanicFromMyOrg();
        totalRecs = mechanics.size();
        limitList();
    }

    public void saveMechanic () {
        HP_MechanicRestService.MechanicDTO addMechanic = new HP_MechanicRestService.MechanicDTO();
        List<HP_MechanicRESTService.MechanicDTO> addMechanics = new List<HP_MechanicRESTService.MechanicDTO>();
        addMechanic.mechanicId = mechanic.Id;
        addMechanic.firstName = mechanic.First_Name__c;
        addMechanic.lastName = mechanic.Name;
        addMechanic.country = mechanic.Nation__c;
        addMechanic.phone = mechanic.Phone__c;
        addMechanic.email = mechanic.Email__c;
        addMechanics.add(addMechanic);
        AsyncCallouts callout = new AsyncCallouts(addMechanics, 'post');
        response = callout.post();
        errorMsg = setMessage(response.message);
        messageType = 'error';
        if (!errorMsg.equals(System.Label.SuccessOperation)) {
            return;
        }
        if (mechanics.size() > 0) {
            searchMechanic();
        }
        messageType = 'success';
    }

    public void updateMechanic () {
        List<HP_MechanicRESTService.MechanicDTO> updateMechanics = new List<HP_MechanicRESTService.MechanicDTO>();
        response = new HP_MechanicRESTService.ResponseREST('');

        HP_MechanicRestService.MechanicDTO mechanicUpdate = new HP_MechanicRestService.MechanicDTO();
        mechanicUpdate.mechanicId = mechanic.SearchId__c;
        mechanicUpdate.firstName = mechanic.First_Name__c;
        mechanicUpdate.lastName = mechanic.Name;
        mechanicUpdate.country = mechanic.Nation__c;
        mechanicUpdate.email = mechanic.Email__c;
        mechanicUpdate.phone = mechanic.Phone__c;
        mechanicUpdate.isSync = true;
        updateMechanics.add(mechanicUpdate);

        if (mechanic.ExternalSystem__c) {
            AsyncCallouts callout = new AsyncCallouts(updateMechanics, 'update');
            response = callout.updateMechanic();
        } else if (mechanic.MySystem__c) {
            Mechanic__c toUpdate = getMyMechanic(mechanicId);
            mechanic.Id = toUpdate.Id;
            update mechanic;
        }

        errorMsg = setMessage(response.message);
        messageType = 'error';
        if (!errorMsg.equals(System.Label.SuccessOperation)) {
            return;
        }
        messageType = 'success';
    }

    public void deleteMechanic () {
        List<HP_MechanicRESTService.MechanicDTO> deleteMechanics = new List<HP_MechanicRESTService.MechanicDTO>();
        response = new HP_MechanicRESTService.ResponseREST('');
        for (Mechanic__c mechanicInList : mechanics) {
            if (mechanicInList.SearchId__c == mechanicId) {
                HP_MechanicRESTService.MechanicDTO deleteMechanic = new HP_MechanicRESTService.MechanicDTO();
                deleteMechanic.mechanicId = mechanicId;
                deleteMechanics.add(deleteMechanic);

                if (mechanicInList.ExternalSystem__c) {
                    AsyncCallouts callout = new AsyncCallouts(deleteMechanics, 'delete');
                    response = callout.deleteMechanic();
                } else if (mechanicInList.MySystem__c) {
                    delete mechanicInList;
                }
                mechanics.remove(mechanics.indexOf(mechanicInList));
                limitList();

                errorMsg = setMessage(response.message);
                messageType = 'error';
                if (!errorMsg.equals(System.Label.SuccessOperation)) {
                    return;
                }
                messageType = 'success';
                break;
            }
        }
    }

    private String setMessage (String responseMessage) {
        String message = responseMessage;
        message = responseMessage.contains('DUPLICATES_DETECTED') ? System.Label.DuplicatedMechanic : message;
        message = responseMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? System.Label.OnlyLetter : message;
        message = responseMessage.contains('INVALID_EMAIL_ADDRESS') ? System.Label.InvalidEmail : message;
        message = responseMessage.contains('ucce') ? System.Label.SuccessOperation : message;
        return message;
    }

    private List<Mechanic__c> getCustomMechanic (List<HP_MechanicRestService.MechanicDTO> mechanicDTOs) {
        List<Mechanic__c> mechanics = new List<Mechanic__c>();
        if (mechanicDTOs != null) {
            for (HP_MechanicRestService.MechanicDTO mechanicDTO : mechanicDTOs) {
                Mechanic__c customMechanic = new Mechanic__c();
                customMechanic.SearchId__c = mechanicDTO.mechanicId;
                customMechanic.First_Name__c = mechanicDTO.firstName;
                customMechanic.Name = mechanicDTO.lastName;
                customMechanic.Nation__c = mechanicDTO.country;
                customMechanic.Phone__c = mechanicDTO.phone;
                customMechanic.Email__c = mechanicDTO.email;
                customMechanic.ExternalId__c = mechanicDTO.externalId;
                mechanics.add(customMechanic);
            }
        }
        return mechanics;
    }

    public void setMechanicProperties () {
        for (Mechanic__c mechanicIter : mechanics) {
            if (mechanicIter.SearchId__c == mechanicId) {
                mechanic = mechanicIter;
                mechanicNewValues = mechanicIter;
            }
        }
    }

    private void getMechanicFromMyOrg () {
        HP_MechanicRESTService.MechanicDTO mechanicDTO = new HP_MechanicRESTService.MechanicDTO();
        mechanicDTO.firstName = mechanicFields.First_Name__c;
        mechanicDTO.lastName = mechanicFields.Name;
        mechanicDTO.country = mechanicFields.Nation__c;
        List<Mechanic__c> myMechanics = searchMechanics(mechanicDTO);
        List<Id> externalIds = new List<Id>();
        List<Id> myIds = new List<Id>();

        for (Mechanic__c mechanic : myMechanics) {
            myIds.add(mechanic.Id);
        }

        for (Mechanic__c mechanic : mechanics) {
            externalIds.add(mechanic.ExternalId__c);
            mechanic.ExternalSystem__c = true;
            if (mechanic.ExternalId__c != null) {
                if (myIds.contains(mechanic.ExternalId__c)) {
                    mechanic.MySystem__c = true;
                } else {
                    mechanic.MySystem__c = false;
                }
            }
        }

        for (Mechanic__c myMechanic : myMechanics) {
            myMechanic.SearchId__c = myMechanic.Id;
            myMechanic.MySystem__c = true;
            if (!externalIds.contains(myMechanic.Id)) {
                myMechanic.ExternalSystem__c = false;
                mechanics.add(myMechanic);
            }
        }
    }

    private Mechanic__c getMyMechanic (String id) {
        return [
                SELECT Id
                FROM Mechanic__c
                WHERE Id = :id
        ];
    }

    private static List<Mechanic__c> searchMechanics (HP_MechanicRESTService.MechanicDTO mechanic) {
        List<Mechanic__c> mechanics = new List<Mechanic__c>();
        List<String> conditions = new List<String>();

        String query =
                'SELECT Id, First_Name__c, Name, Country__c, Nation__c, Email__c, Salary__c, Born__c, Phone__c, ExternalId__c ' +
                        'FROM Mechanic__c ';
        conditions.clear();


        if (mechanic.lastName != null && mechanic.lastName != '') {
            conditions.add('Name LIKE' + '\'%' + mechanic.lastName + '%\'');
        }
        if (mechanic.firstName != null && mechanic.firstName != '') {
            conditions.add('First_Name__c LIKE' + '\'%' + mechanic.firstName + '%\'');
        }
        if (mechanic.country != null && mechanic.country != '') {
            conditions.add('Nation__c LIKE' + '\'%' + mechanic.country + '%\'');
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

    public void clear () {
        totalRecs = 0;
        mechanics.clear();
        mechanicFields = new Mechanic__c();
        clearMechanic();
    }

    public void clearMechanic () {
        mechanic = new Mechanic__c();
    }

    public void limitList () {
        mechanicList = new List<Mechanic__c>();
        Integer maxLimit;

        if (offsetSize < 0) {
            offsetSize = 0;
        }
        if (mechanics.size() < size + offsetSize) {
            maxLimit = mechanics.size();
        } else {
            maxLimit = offsetSize + size;
        }

        for (Integer i = offsetSize; i < maxLimit; i++) {
            mechanicList.add(mechanics.get(i));
        }
    }

    public void firstPage () {
        offsetSize = 0;
        limitList();
    }

    public void previousPage () {
        offsetSize = (offsetSize - size);
        limitList();
    }

    public void nextPage () {
        offsetSize = offsetSize + size;
        limitList();
    }

    public void lastPage () {
        offsetSize = totalRecs - Math.mod(totalRecs, size);
        limitList();
    }
}