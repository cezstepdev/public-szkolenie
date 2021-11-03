({
    onSelectedItem: function (component, event, helper) {
        let item = event.getParam("item");
        component.set("v.item", item);

        // let action = component.get("c.getApprovalInfo");
        // action.setParams(
        //     {
        //         id: item.id
        //     }
        // );
        //
        // action.setCallback(this, function (response) {
        //     if(response.getState() === 'SUCCESS') {
        //         component.set("v.comment", response.getReturnValue());
        //         $A.get("e.c:SpinnerHideEvent").fire();
        //     }
        // });
        //
        // $A.enqueueAction(action);
    },

    // editMovie: function (component, event, helper) {
    //     let modalBody;
    //     $A.createComponents(
    //         [
    //             ["c:MOV_MovieEditModal",{
    //                 item : component.get("v.item")
    //             }]
    //         ],
    //         function(content, status) {
    //             if (status === "SUCCESS") {
    //                 modalBody = content[0];
    //                 component.find('overlayLib').showCustomModal({
    //                     header: "Edit movie",
    //                     body: modalBody,
    //                     showCloseButton: true,
    //                 })
    //             }
    //         }
    //     );
    // },
    //
    // deleteMovie: function (component, event, helper) {
    //     let modalBody;
    //     let modalFooter;
    //     $A.createComponents(
    //         [
    //             ["c:MOV_MovieDeleteModal",{
    //                 item : component.get("v.item")
    //             }],
    //             ["c:MOV_MovieDeleteFooter",{
    //                 item : component.get("v.item")
    //             }]
    //         ],
    //         function(content, status) {
    //             if (status === "SUCCESS") {
    //                 modalBody = content[0];
    //                 modalFooter = content[1];
    //                 component.find('overlayLib').showCustomModal({
    //                     header: "Delete movie",
    //                     body: modalBody,
    //                     footer: modalFooter,
    //                     showCloseButton: true
    //                 })
    //             }
    //         }
    //     );
    // }
})