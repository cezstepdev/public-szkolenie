({
    handleSuccess: function (cmp) {
        let event = $A.get("e.c:MOV_EventEditMovie");
        event.setParams(
            {
                id: cmp.get("v.item.id")
            }
        );
        event.fire();

        cmp.find('overlayLib').notifyClose();
        $A.get("e.c:SpinnerHideEvent").fire();
    },

    handleError: function (cmp, event, helper) {
        cmp.find('overlayLib').notifyClose();
    }
})