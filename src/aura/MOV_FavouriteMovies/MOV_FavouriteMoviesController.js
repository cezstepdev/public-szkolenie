({
    doInit: function (component) {
        let action = component.get("c.getLikedMovies");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.movies", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})