({
    handleSuccess: function (cmp) {
        let event = $A.get("e.c:DoSearch");
        event.setParams({
            accountId: cmp.get("v.account.Id")
        });
        event.fire();
        cmp.find('overlayLib').notifyClose();
    },

    handleError: function (cmp, event, helper) {
        cmp.find('overlayLib').notifyClose();
    }
})