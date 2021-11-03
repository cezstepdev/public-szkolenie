({
    onSelectedItem: function (component, event, helper) {
        let item = event.getParam("item");
        let cast = event.getParam("cast");
        component.set("v.item", item);
        component.set("v.cast", cast);

        let getAverageRating = component.get("c.getAverageRating");

        getAverageRating.setParams(
            {
                id: component.get("v.item.id")
            }
        );

        getAverageRating.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS') {
                component.set("v.averageRating", response.getReturnValue());
            } else {
                component.set("v.averageRating", 0.0);
            }
            $A.get("e.c:SpinnerHideEvent").fire();
        });
        $A.enqueueAction(getAverageRating);

        let getApprovalInfoAction = component.get("c.getApprovalInfo");
        getApprovalInfoAction.setParams(
            {
                id: component.get("v.item.id")
            }
        );

        getApprovalInfoAction.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS') {
                component.set("v.comment", response.getReturnValue());
                $A.get("e.c:SpinnerHideEvent").fire();
            }
        });

        $A.enqueueAction(getApprovalInfoAction);
    },

    editMovie: function (component, event, helper) {
        let modalBody;
        $A.createComponents(
            [
                ["c:MOV_MovieEditModal",{
                    item : component.get("v.item")
                }]
            ],
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content[0];
                    component.find('overlayLib').showCustomModal({
                        header: "Edit movie",
                        body: modalBody,
                        showCloseButton: true,
                    })
                }
            }
        );
    },

    deleteMovie: function (component, event, helper) {
        let modalBody;
        let modalFooter;
        $A.createComponents(
            [
                ["c:MOV_MovieDeleteModal",{
                    item : component.get("v.item")
                }],
                ["c:MOV_MovieDeleteFooter",{
                    item : component.get("v.item")
                }]
            ],
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content[0];
                    modalFooter = content[1];
                    component.find('overlayLib').showCustomModal({
                        header: "Delete movie",
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: true
                    })
                }
            }
        );
    }
})