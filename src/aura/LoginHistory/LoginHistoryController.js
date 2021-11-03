({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Login ID', fieldName: 'Id', type: 'text', hideDefaultActions: true},
            {label: 'Login Type', fieldName: 'LoginType', type: 'text', hideDefaultActions: true},
            {
                label: 'Login Date', fieldName: 'LoginTime', type: 'date', typeAttributes: {
                    day: "numeric",
                    month: "numeric",
                    year: "numeric"
                }, hideDefaultActions: true
            }
        ]);
    }
})