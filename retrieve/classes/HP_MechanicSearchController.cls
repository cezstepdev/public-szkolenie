public class HP_MechanicSearchController {
    public List<MW_MechanicSOAP.MechanicDTO> mechanicDTOs { get; set; }
    private MW_MechanicSOAP.MA_MechanicSOAPService mechanicService { get; set; }

    public List<Mechanic__c> mechanicList { get; set; }
    public List<Mechanic__c> mechanics { get; set; }
    public Mechanic__c mechanic { get; set; }
    public String mechanicId { get; set; }
    public Mechanic__c mechanicFields { get; set; }
    public Mechanic__c mechanicNewValues { get; set; }
    public MW_MechanicSOAP.SOAPResponse response { get; set; }

    public String errorMsg { get; set; }
    public String messageType { get; set; }

    public Integer size { get; set; }
    public List<SelectOption> paginationSizeOptions { get; set; }
    public Integer totalRecs { get; set; }
    public Integer offsetSize { get; set; }

    public HP_MechanicSearchController () {
        mechanic = new Mechanic__c();
        mechanics = new List<Mechanic__c>();
        mechanicDTOs = new List<MW_MechanicSOAP.MechanicDTO>();
        mechanicFields = new Mechanic__c();
        mechanicNewValues = new Mechanic__c();
        mechanicService = new MW_MechanicSOAP.MA_MechanicSOAPService();

        size = 5;
        totalRecs = 0;
        offsetSize = 0;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('1', '1'));
        paginationSizeOptions.add(new SelectOption('2', '2'));
        paginationSizeOptions.add(new SelectOption('5', '5'));
        paginationSizeOptions.add(new SelectOption('10', '10'));
        paginationSizeOptions.add(new SelectOption('15', '15'));

        MW_MechanicSOAP.SessionHeader_element webserviceSessionHeader = new MW_MechanicSOAP.SessionHeader_element();
        webserviceSessionHeader.sessionId = (String) Cache.Org.getPartition('local.SessionIdCache').get('sessionId');
        mechanicService.SessionHeader = webserviceSessionHeader;
    }

    public void searchMechanic () {
        offsetSize = 0;
        try {
            if (String.isEmpty((String) Cache.Org.getPartition('local.SessionIdCache').get('sessionId'))) {
                connect();
            }
            mechanicDTOs = mechanicService.getMechanics(mechanicFields.First_Name__c, mechanicFields.Name, mechanicFields.Nation__c);
        } catch (Exception e) {
            if (e.getMessage().contains('INVALID_SESSION_ID')) {
                connect();
                mechanicDTOs = mechanicService.getMechanics(mechanicFields.First_Name__c, mechanicFields.Name, mechanicFields.Nation__c);
            }
        }
        mechanics = getCustomMechanic(mechanicDTOs);
        totalRecs = mechanics.size();
        limitList();
    }

    public void saveMechanic () {
        MW_MechanicSOAP.MechanicDTO addMechanic = new MW_MechanicSOAP.MechanicDTO();
        List<MW_mechanicSOAP.MechanicDTO> addMechanics = new List<MW_mechanicSOAP.MechanicDTO>();
        addMechanic.firstName = mechanic.First_Name__c;
        addMechanic.lastName = mechanic.Name;
        addMechanic.country = mechanic.Nation__c;
        addMechanic.phone = mechanic.Phone__c;
        addMechanic.email = mechanic.Email__c;
        addMechanics.add(addMechanic);
        try {
            if (String.isEmpty((String) Cache.Org.getPartition('local.SessionIdCache').get('sessionId'))) {
                connect();
            }
            response = mechanicService.postMechanicList(addMechanics);
        } catch (Exception e) {
            if (e.getMessage().contains('INVALID_SESSION_ID')) {
                connect();
                response = mechanicService.postMechanicList(addMechanics);
            }
        }
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
        List<MW_mechanicSOAP.MechanicDTO> updateMechanics = new List<MW_mechanicSOAP.MechanicDTO>();

        MW_MechanicSOAP.MechanicDTO mechanicUpdate = new MW_MechanicSOAP.MechanicDTO();
        mechanicUpdate.mechanicId = mechanicId;
        mechanicUpdate.firstName = mechanic.First_Name__c;
        mechanicUpdate.lastName = mechanic.Name;
        mechanicUpdate.country = mechanic.Nation__c;
        mechanicUpdate.email = mechanic.Email__c;
        mechanicUpdate.phone = mechanic.Phone__c;
        updateMechanics.add(mechanicUpdate);
        try {
            if (String.isEmpty((String) Cache.Org.getPartition('local.SessionIdCache').get('sessionId'))) {
                connect();
            }
            response = mechanicService.updateMechanicList(updateMechanics);
        } catch (Exception e) {
            if (e.getMessage().contains('INVALID_SESSION_ID')) {
                connect();
                response = mechanicService.updateMechanicList(updateMechanics);
            }
        }

        errorMsg = setMessage(response.message);
        messageType = 'error';
        if (!errorMsg.equals(System.Label.SuccessOperation)) {
            return;
        }
        messageType = 'success';
    }

    public void deleteMechanic () {
        List<Id> mechanicsId = new List<Id>();
        for (Mechanic__c mechanicInList : mechanics) {
            if (mechanicInList.Id == mechanic.Id) {
                mechanicsId.add(mechanic.Id);
                try {
                    if (String.isEmpty((String) Cache.Org.getPartition('local.SessionIdCache').get('sessionId'))) {
                        connect();
                    }
                    response = mechanicService.deleteMechanicList(mechanicsId);
                } catch (Exception e) {
                    if (e.getMessage().contains('INVALID_SESSION_ID')) {
                        connect();
                        response = mechanicService.deleteMechanicList(mechanicsId);
                    }
                }
                errorMsg = setMessage(response.message);
                messageType = 'error';
                if (!errorMsg.equals(System.Label.SuccessOperation)) {
                    return;
                }
                searchMechanic();
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

    private void connect () {
        String username;
        String password;
        String token;

        username = SOAPCredential__c.getValues('PawelOrg') ?.Username__c;
        password = SOAPCredential__c.getValues('PawelOrg') ?.Password__c;
        token = SOAPCredential__c.getValues('PawelOrg') ?.Token__c;

        partnerSoapSforceCom.Soap myPartnerSoap = new partnerSoapSforceCom.Soap();
        partnerSoapSforceCom.LoginResult partnerLoginResult = myPartnerSoap.login(username, password + token);
        MW_MechanicSOAP.SessionHeader_element webserviceSessionHeader = new MW_MechanicSOAP.SessionHeader_element();
        webserviceSessionHeader.sessionId = partnerLoginResult.sessionId;
        mechanicService.SessionHeader = webserviceSessionHeader;
        Cache.Org.put('local.SessionIdCache.sessionId', partnerLoginResult.sessionId);
    }

    private List<Mechanic__c> getCustomMechanic (List<MW_MechanicSOAP.MechanicDTO> mechanicDTOs) {
        List<Mechanic__c> mechanics = new List<Mechanic__c>();
        if (mechanicDTOs != null) {
            for (MW_MechanicSOAP.MechanicDTO mechanicDTO : mechanicDTOs) {
                Mechanic__c customMechanic = new Mechanic__c();
                customMechanic.ExternalId__c = mechanicDTO.mechanicId;
                customMechanic.First_Name__c = mechanicDTO.firstName;
                customMechanic.Name = mechanicDTO.lastName;
                customMechanic.Country__c = mechanicDTO.country;
                customMechanic.Phone__c = mechanicDTO.phone;
                customMechanic.Email__c = mechanicDTO.email;
                mechanics.add(customMechanic);
            }
        }
        return mechanics;
    }

    public void setMechanicProperties () {
        for (Mechanic__c mechanicIter : mechanics) {
            if (mechanicIter.ExternalId__c == mechanicId) {
                mechanic = mechanicIter;
                mechanic.Nation__c = mechanicIter.Country__c;
                mechanicNewValues.First_Name__c = mechanicIter.First_Name__c;
                mechanicNewValues.Name = mechanicIter.Name;
                mechanicNewValues.Phone__c = mechanicIter.Phone__c;
                mechanicNewValues.Email__c = mechanicIter.Email__c;
                mechanicNewValues.Country__c = mechanicIter.Country__c;
            }
        }
    }

    public void clear () {
        totalRecs = 0;
        mechanics.clear();
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