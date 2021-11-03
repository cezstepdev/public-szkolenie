({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
            {label: "Name", fieldName: "linkName", type: "url", typeAttributes: {
                label: { fieldName: "Name" }, target: "‘_blank’"}, hideDefaultActions: true},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {
                    day: "numeric",
                    month: "numeric",
                    year: "numeric"
                }, hideDefaultActions: true},
            {label: 'CreatedBy', fieldName: 'CreatedBy', type: 'text', hideDefaultActions: true},
            {label: 'Api Version', fieldName: 'ApiVersion', type: 'text', hideDefaultActions: true}
        ]);
        helper.fetchData(component);
    },
})