({
    fetchData: function (component) {
        let action = component.get("c.getAllPages");

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let pages = response.getReturnValue();
                let pageWrapper = [];
                for (let page of pages) {
                    pageWrapper.push({
                        linkName: 'https://britenet67-dev-ed.lightning.force.com/lightning/setup/ApexPages/page?address=%2F' + page.Id,
                        Name: page.Name,
                        CreatedDate: page.CreatedDate,
                        CreatedBy: page.CreatedBy.Name,
                        ApiVersion: page.ApiVersion
                    });
                }
                component.set('v.data', pageWrapper);
            }
        });

        $A.enqueueAction(action);
    },
})