({
    onInit: function (component) {
        let action = component.get("c.getMovies");
        action.setParams(
            {
                title: ''
            }
        );

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.item", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },
})