({
    deleteAccount: function (component) {
        component.find("recordHandler").deleteRecord($A.getCallback(function(deleteResult) {
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Deleted",
                    "message": "The record was deleted."
                });
                resultsToast.fire();
                let event = $A.get("e.c:MOV_EventEditMovie");
                event.fire();
                $A.get("e.c:SpinnerHideEvent").fire();
                let hideDetail = $A.get("e.c:MOV_MovieSelectedItem");
                hideDetail.setParams(
                    {
                        item: null
                    }
                );
                hideDetail.fire();
            }
            else {
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Can not delete this record",
                    "message": deleteResult.error[0].message
                });
                resultsToast.fire();
            }
            component.find('overlayLib').notifyClose();
        }));
    },

    closeDialog: function (component) {
        component.find('overlayLib').notifyClose();
    }
})