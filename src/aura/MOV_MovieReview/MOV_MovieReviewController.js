({
    doInit : function(component, event, helper) {
        let movie = component.get("v.movie");
        if(movie !== null && movie !== undefined) {
            let action = component.get("c.getAll");
            action.setParams(
                {
                    "id": movie.id
                }
            );
            action.setCallback(this, function(response){
                let state = response.getState();
                switch(state){
                    case "SUCCESS":
                        let movieReviews = response.getReturnValue();
                        component.set("v.movieReviews", movieReviews);
                        break;

                    case "INCOMPLETE":
                        break;

                    case "ERROR":
                        break;
                }

            });
            $A.enqueueAction(action);
        }
    },

    onUserInfoClick : function(component, event, helper) {
        let userId = event.target.getAttribute("data-userid");
        let redirectEvent = $A.get("e.force:navigateToSObject");
        if(redirectEvent){
            redirectEvent.setParams({ "recordId": userId});
            redirectEvent.fire();
        }
    }
})