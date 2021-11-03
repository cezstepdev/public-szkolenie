({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
            {label: "Login Type", fieldName: "LoginType", type: "text", hideDefaultActions: true},
            {label: 'Session Type', fieldName: 'SessionType', type: 'text', hideDefaultActions: true},
            {label: 'Source IP', fieldName: 'SourceIp', type: 'text', hideDefaultActions: true}
        ]);
        helper.fetchData(component);
    },
})