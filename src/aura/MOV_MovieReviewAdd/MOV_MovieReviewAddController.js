({
    doInit: function(component, event, helper) {
        helper.doInit(component);
    },

    onSave:function(component, event, helper) {
        component.set("v.movieReview.movieId__c", component.get("v.movie.id"));
        component.find("service").saveRecord(function(saveResult) {
            $A.get('e.c:SpinnerShowEvent').fire();
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                let resultsToast = $A.get("e.force:showToast");
                if(resultsToast == undefined){
                    alert("The record was saved.");
                }else{
                    resultsToast.setParams({
                        "title": "Success",
                        "message": "Your comment was added"
                    });
                    resultsToast.fire();
                    helper.doInit(component);
                    $A.get('e.c:MOV_MovieReviewAdded').fire();
                }
            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                console.log('Problem saving contact, error: ' +
                    JSON.stringify(saveResult.error));
                let resultsToast = $A.get("e.force:showToast");
                if(resultsToast == undefined) {
                    alert("The record was saved.");
                } else {
                    resultsToast.setParams({
                        "title": "Error",
                        "message": saveResult.error[0].message.slice(9,29)
                    });
                    resultsToast.fire();
                }
            } else {
                console.log('Unknown problem, state: ' + saveResult.state +
                    ', error: ' + JSON.stringify(saveResult.error));
            }

            let spinnerHide = $A.get('e.c:SpinnerHideEvent');

            setTimeout(() => {
                spinnerHide.fire();
            }, 2000);

        });
    },
})