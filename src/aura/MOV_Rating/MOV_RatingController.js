({
    doInit: function (component) {
        let action = component.get("c.checkReviewExist");

        action.setParams(
            {
                id: component.get("v.item.id")
            }
        );

        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS') {
                let reviewExist = response.getReturnValue();
                if(reviewExist) {
                    component.set("v.displayAddReview", false);
                } else {
                    component.set("v.displayAddReview", true);
                }
            }
        });
        $A.enqueueAction(action);
    },
})