({
    fetchData: function (component) {
        let action = component.get("c.getSession");

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let session = response.getReturnValue();
                component.set('v.data', session);
            }
        });

        $A.enqueueAction(action);
    },
})