({
    doInit: function (component) {
        let action = component.get("c.getDislikedMovies");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.movies", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})