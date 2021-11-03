public with sharing class AsyncCallouts implements Queueable, Database.AllowsCallouts {

    private List<HP_MechanicRESTService.MechanicDTO> mechanicDTOS;
    private String type;
    private HP_MechanicRESTService.ResponseREST response = new HP_MechanicRESTService.ResponseREST('');

    public AsyncCallouts(List<HP_MechanicRESTService.MechanicDTO> mechanicDTOS, String type) {
        this.mechanicDTOS = mechanicDTOS;
        this.type = type;
    }

    public HP_MechanicRESTService.ResponseREST post() {
        if(String.isEmpty((String) Cache.Org.getPartition('local.TokenCache').get('accessToken'))) {
            HP_MechanicRESTCallouts.login();
        }
        response = HP_MechanicRESTCallouts.postMechanics(mechanicDTOS);
        if(response.message.contains('INVALID_SESSION_ID')) {
            HP_MechanicRESTCallouts.login();
            response = HP_MechanicRESTCallouts.postMechanics(mechanicDTOS);
        }
        return response;
    }

    public HP_MechanicRESTService.ResponseREST deleteMechanic() {
        if(String.isEmpty((String) Cache.Org.getPartition('local.TokenCache').get('accessToken'))) {
            HP_MechanicRESTCallouts.login();
        }
        response = HP_MechanicRESTCallouts.deleteMechanics(mechanicDTOS);
        if(response.message.contains('INVALID_SESSION_ID')) {
            HP_MechanicRESTCallouts.login();
            response = HP_MechanicRESTCallouts.deleteMechanics(mechanicDTOS);
        }
        return response;
    }

    public HP_MechanicRESTService.ResponseREST updateMechanic() {
        if(String.isEmpty((String) Cache.Org.getPartition('local.TokenCache').get('accessToken'))) {
            HP_MechanicRESTCallouts.login();
        }
        response = HP_MechanicRESTCallouts.updateMechanics(mechanicDTOS);
        if(response.message.contains('INVALID_SESSION_ID')) {
            HP_MechanicRESTCallouts.login();
            response = HP_MechanicRESTCallouts.updateMechanics(mechanicDTOS);
        }
        return response;
    }

    public void execute(QueueableContext context) {
        if(type == 'post') {
            post();
        }

        if(type == 'delete') {
            deleteMechanic();
        }

        if(type == 'update') {
            updateMechanic();
        }
    }
}