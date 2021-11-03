({
    doInit: function (component, event) {
        let action = component.get("c.getMyMovies");

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.movies", response.getReturnValue());
                // if(event.getParam("id") != null) {
                //     let event = $A.get("e.c:MOV_EventEditMovie");
                //     event.setParams(
                //         {
                //             id: event.getParam("id")
                //         }
                //     );
                //     event.fire();
                // }
            }
        });
        $A.enqueueAction(action);

    }
})