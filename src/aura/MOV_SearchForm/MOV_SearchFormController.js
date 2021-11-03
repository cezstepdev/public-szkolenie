({
    doInit: function(component, event, helper) {
        helper.onInit(component);
    },

    getItems: function (component) {
        let movieSendParam = $A.get("e.c:MOV_MovieSelectedItem");
        movieSendParam.setParams(
            {
                item: undefined,
                cast: []
            }
        );
        movieSendParam.fire();

        let actorSendParam = $A.get("e.c:MOV_SelectedItem");
        actorSendParam.setParams(
            {
                item: null,
                movies: []
            }
        );
        actorSendParam.fire();

        let sendParam = $A.get("e.c:MOV_EventItemSearchParameter");
        sendParam.setParams(
            {
                parameter: component.get("v.parameter"),
                page: 1
            }
        );
        sendParam.fire();
    },

    onInputChange: function (component) {
        let input = component.find("searchInput").get("v.value");
        if(input.length > 2) {
            component.set("v.disableButton", false);
        } else {
            component.set("v.disableButton", true);
        }
    }
})