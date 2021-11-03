({
    onClick: function (component, event, helper) {
        let action = component.get("c.getAllDetails");
        let user = component.get("v.user");

        action.setParams({
           userId: userId
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let detail = response.getReturnValue();

                component.set("v.details", {
                    Country: detail.Country,
                    Phone: detail.Phone
                });
            }
        });

        $A.enqueueAction(action);
    }
})