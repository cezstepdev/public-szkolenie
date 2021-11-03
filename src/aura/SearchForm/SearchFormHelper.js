({
    onInit: function (component) {
        component.set("v.newItem",
            {
                sObjectType: 'Account',
                Name: ''
            }
        );
    },

    getAccounts: function (component, event) {
        const spinner = component.find("spinner");
        spinner.showSpinner();
        let action = component.get("c.getAll");
        action.setParams(
            {
                name: component.get("v.newItem.Name")
            }
        );

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let getAccounts = $A.get("e.c:AccountGet");
                getAccounts.setParams(
                    {
                        objectList: response.getReturnValue()
                    }
                );
                setTimeout(function () {
                    getAccounts.fire();
                    spinner.hideSpinner();
                }, 1100);
            }
        });
        $A.enqueueAction(action);
    },
})