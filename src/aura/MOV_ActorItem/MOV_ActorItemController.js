({
    onImageClick: function (component, event) {
        $A.get("e.c:SpinnerShowEvent").fire();
        let action = component.get("c.getMovies");
        action.setParams(
            {
                id: component.get("v.actor.id")
            }
        );

        let actorDetails = component.get("c.getActorDetails");
        actorDetails.setParams(
            {
                id: component.get("v.actor.id")
            }
        );
        actorDetails.setCallback(this, function(detailResponse) {
            let state = detailResponse.getState();
            let actor = detailResponse.getReturnValue();
            if (state === "SUCCESS") {
                action.setCallback(this, function(response) {
                    let state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.movies", response.getReturnValue());

                        let movieSendParam = $A.get("e.c:MOV_MovieSelectedItem");
                        movieSendParam.setParams(
                            {
                                item: null,
                                cast: []
                            }
                        );
                        movieSendParam.fire();

                        let actorSendParam = $A.get("e.c:MOV_SelectedItem");
                        actorSendParam.setParams(
                            {
                                item: actor,
                                movies: component.get("v.movies")
                            }
                        );
                        actorSendParam.fire();

                        $A.get("e.c:MOV_EventItemClick").fire();
                    }});

                $A.enqueueAction(action);
            }});
        $A.enqueueAction(actorDetails);
    },
})