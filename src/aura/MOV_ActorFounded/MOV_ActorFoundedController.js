({
    onParameterGet: function (component, event, helper) {
        component.set("v.parameter", event.getParam("parameter"));
        let action = component.get("c.getActors");
        action.setParams(
            {
                name: component.get("v.parameter")
            }
        );

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.item", response.getReturnValue());
                const spinner = component.find("spinner");
                spinner.hideSpinner();
            }
        });

        $A.enqueueAction(action);
    },

    onItemClick: function (component) {
        component.set("v.item", []);
    }
})