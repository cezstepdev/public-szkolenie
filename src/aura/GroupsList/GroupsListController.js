({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Group ID', fieldName: 'Id', type: 'text', hideDefaultActions: true},
            {label: 'Group Name', fieldName: 'Group', type: 'text', hideDefaultActions: true}
        ]);
    }
})