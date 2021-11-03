({
    doInit: function(component, event, helper) {
        helper.onInit(component);
    },

    getAccounts: function (component, event, helper) {
        helper.getAccounts(component, event);
    },

    clear: function (component) {
        component.set("v.newItem.Name", "");

        let event = $A.get("e.c:AccountGet");
        event.setParams(
            {
                objectList: []
            }
        );
        event.fire();
    }
})