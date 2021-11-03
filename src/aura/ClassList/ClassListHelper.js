({
    fetchData: function (component) {
        let action = component.get("c.getAllClasses");

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let classes = response.getReturnValue();
                let classWrapper = [];
                for (let class1 of classes) {
                    classWrapper.push({
                        linkName: 'https://britenet67-dev-ed.lightning.force.com/lightning/setup/ApexClasses/page?address=%2F' + class1.Id,
                        Name: class1.Name,
                        CreatedDate: class1.CreatedDate,
                        CreatedBy: class1.CreatedBy.Name,
                        ApiVersion: class1.ApiVersion
                    });
                }
                component.set('v.data', classWrapper);
            }
        });

        $A.enqueueAction(action);
    },
})