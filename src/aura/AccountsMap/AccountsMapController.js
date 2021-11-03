({
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
    },

    accountsListChange: function(component, event, helper) {
        let accounts = component.get("v.accounts");
        let accountsList = [];

        for (let account of accounts) {
            let accountsListElement;
            if(account.Latitude__c !== undefined) {
                 accountsListElement = {
                    location: {
                        Latitude: account.Latitude__c,
                        Longitude: account.Longitude__c
                    },
                    title: account.Name
                };
            }
            else {
                accountsListElement = {
                    location: {
                        City: account.BillingCity,
                        Country: account.BillingCountry
                    },
                    title: account.Name
                };
            }
            accountsList.push(accountsListElement);
        }
        component.set('v.mapMarkers', accountsList);
    },

    onAccountSelect: function(component, event, helper) {
        if(event) {
            let account = event.getParam("selectedAccount");
            if(account !== null) {
                if(account.Latitude__c !== undefined) {
                    component.set('v.center', {
                        location: {
                            Latitude: account.Latitude__c,
                            Longitude: account.Longitude__c
                        }
                    });
                    component.set('v.zoomLevel', 10);
                } else if(account.BillingCity !== undefined || account.BillingStreet !== undefined) {
                    component.set('v.center', {
                        location: {
                            City: account.BillingCity,
                            Country: account.BillingCountry
                        }
                    });
                    component.set('v.zoomLevel', 10);
                }
                else {
                    helper.doInit(component, event);
                }
            }
        }
    },

    onAccountGet: function (component, event, helper) {
        helper.doInit(component, event);
        let receivedList = event.getParam("objectList")
        component.set("v.accounts", receivedList);
    }
});