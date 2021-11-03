({
    doInit: function(component) {
        let oppId = component.get("v.recordId");

        let action = component.get("c.get");
        action.setParams({oppId: oppId});
        action.setCallback(this, function (response) {
            component.set('v.isButtonActive', response.getReturnValue().Order_Created__c);
        });
        $A.enqueueAction(action);

        let getProducts = component.get("c.getProducts");
        getProducts.setParams({oppId: oppId});
        getProducts.setCallback(this, function (response) {
            component.set('v.products', response.getReturnValue());
        });
        $A.enqueueAction(getProducts);

        let getQuotes = component.get("c.quoteAccepted");
        getQuotes.setParams({id: oppId});
        getQuotes.setCallback(this, function (response) {
            component.set('v.quotes', response.getReturnValue());
            if(!response.getReturnValue()) {
                component.set('v.isButtonActive', true);
            }
        });
        $A.enqueueAction(getQuotes);

        let getStage = component.get("c.getStage");
        getStage.setParams({oppId: oppId});
        getStage.setCallback(this, function (response) {
            component.set('v.stage', response.getReturnValue());
            if(!response.getReturnValue()) {
                component.set('v.isButtonActive', true);
            }
        });
        $A.enqueueAction(getStage);
    },

    createOrderAction: function (component, event, helper) {
        $A.get("e.c:SpinnerShowEvent").fire();
        let action = component.get("c.createOrder");
        let oppId = component.get("v.recordId");

        action.setParams({oppId: oppId});
        action.setCallback(this, function (response) {
            component.set("v.order", response.getReturnValue());
            let message = response.getReturnValue().length == 0 ? 'Opportunity conversion failed' : 'Success';

            if(message == 'Success') {
                component.set('v.isButtonActive', true);
                $A.get("e.c:SpinnerHideEvent").fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://britenet67-dev-ed.lightning.force.com/" + response.getReturnValue()[0].Id
                });
                urlEvent.fire();
            } else {
                let modalBody;
                $A.createComponents(
                    [
                        ["c:CreateOrderDialog",{
                            message: message,
                        }]
                    ],
                    function(content, status) {
                        if (status === "SUCCESS") {
                            modalBody = content[0];
                            component.find('overlayLib').showCustomModal({
                                header: message,
                                body: modalBody,
                                showCloseButton: true,
                            })
                        }
                    }
                );
            }
        });
        $A.enqueueAction(action);
    }
})