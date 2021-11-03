({
    onAccountGet: function (component, event, helper) {
        let receivedList = event.getParam("objectList")
        component.set("v.accounts", receivedList);
    }
})