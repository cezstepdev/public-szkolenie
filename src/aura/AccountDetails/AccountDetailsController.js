({
    onAccountSelect: function (component, event, helper) {
        let receivedList = event.getParam("selectedAccount")
        component.set("v.account", receivedList);
    },

    onAccountGet: function (component, event, helper) {
        if(event.getParam("objectList").length === 0) {
            component.set("v.account", undefined);
        }
    },

    editAccount: function (component, event, helper) {
        let modalBody;
        $A.createComponents(
            [
                ["c:AccountEditModal",{
                    account : component.get("v.account")
                }]
            ],
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content[0];
                    component.find('overlayLib').showCustomModal({
                        header: "Edit account",
                        body: modalBody,
                        showCloseButton: true,
                    })
                }
            }
        );
    },

    deleteAccount: function (component, event, helper) {
        let modalBody;
        let modalFooter;
        $A.createComponents(
            [
                ["c:AccountDeleteModal",{
                    account : component.get("v.account")
                }],
                ["c:modalFooter",{
                    account : component.get("v.account")
                }]
            ],
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content[0];
                    modalFooter = content[1];
                    component.find('overlayLib').showCustomModal({
                        header: "Delete account",
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: true
                    })
                }
            }
        );
    }
})