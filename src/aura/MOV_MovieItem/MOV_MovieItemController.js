({
    onImageClick: function (component, event) {
        $A.get("e.c:SpinnerShowEvent").fire();
        let movieId;
        if(event.getParam("id") != null) {
            movieId = event.getParam("id");
        } else {
            movieId = component.get("v.movie.id");
        }

        let action = component.get("c.getCast");
        action.setParams(
            {
                id: movieId
            }
        );

        let movieDetail = component.get("c.getMovieDetails");
        movieDetail.setParams(
            {
                id: movieId
            }
        );

        movieDetail.setCallback(this, function(movieDetailResponse) {
            let state = movieDetailResponse.getState();
            let movie = movieDetailResponse.getReturnValue();
            if (state === "SUCCESS") {
                action.setCallback(this, function(response) {
                    let state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.cast", response.getReturnValue());
                        let sendParam = $A.get("e.c:MOV_MovieSelectedItem");
                        sendParam.setParams(
                            {
                                item: movie,
                                cast: component.get("v.cast")
                            }
                        );
                        sendParam.fire();
                        console.log('siema');

                        let actorSendParam = $A.get("e.c:MOV_SelectedItem");
                        actorSendParam.setParams(
                            {
                                item: null,
                                movies: []
                            }
                        );
                        actorSendParam.fire();

                        $A.get("e.c:MOV_EventItemClick").fire();
                    }
                });

                $A.enqueueAction(action);
            }});
        $A.enqueueAction(movieDetail);
    }
})