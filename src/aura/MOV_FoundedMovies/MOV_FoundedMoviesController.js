({
    onParameterGet: function (component, event) {
        const spinner = component.find("spinner");
        spinner.showSpinner();
        component.set("v.parameter", event.getParam("parameter"));
        let action = component.get("c.getMovies");
        action.setParams(
            {
                title: event.getParam("parameter")
            }
        );

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.item", response.getReturnValue());
                spinner.hideSpinner();
            }
        });

        $A.enqueueAction(action);
    },

    onItemClick: function (component) {
        component.set("v.item", []);
    }
})