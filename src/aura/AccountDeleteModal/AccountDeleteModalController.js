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
                $A.get("e.c:DoSearch").fire();
                component.set("v.account", null);
                let event = $A.get("e.c:DoSearch");
                event.fire();
            }
            else {
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Can not delete this record",
                    "message": "The record was not deleted."
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