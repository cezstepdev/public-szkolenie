({
    onInit: function (component) {
        let action = component.get("c.getAll");

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let ORG = response.getReturnValue();

                component.set("v.ORG", {
                    URL: ORG.URL,
                    instance: ORG.instance,
                    sessionAPI: ORG.sessionAPI,
                    sessionVF: ORG.sessionVF,
                    licenceAvailable: ORG.licenceAvailable
                });
            }
        });

        $A.enqueueAction(action);
    },
})