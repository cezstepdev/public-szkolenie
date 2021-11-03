({
    doInit: function (component) {
        let action = component.get("c.getAllLicences");

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let licences = response.getReturnValue();
                let licencesList = [];
                for (let licence of licences) {
                    licencesList.push({
                        Name: licence.Name,
                        UsedLicenses: licence.UsedLicenses,
                        TotalLicenses: licence.TotalLicenses,
                        Percent: (licence.UsedLicenses/licence.TotalLicenses) * 100
                    });
                }
                component.set('v.data', licencesList);
            }
        });

        $A.enqueueAction(action);
    },
})