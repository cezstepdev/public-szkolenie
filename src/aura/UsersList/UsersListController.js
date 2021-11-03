({
    doInit: function (component, event, helper) {
        let rowActions = helper.getRowActions.bind(this, component);

        component.set('v.columns', [
            {label: 'First Name', fieldName: 'FirstName', type: 'text', initialWidth: 280, hideDefaultActions: true},
            {label: 'Last Name', fieldName: 'LastName', type: 'text', initialWidth: 280, hideDefaultActions: true},
            {label: 'Username', fieldName: 'Username', type: 'text', hideDefaultActions: true},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', initialWidth: 280, typeAttributes: {
                    day: "numeric",
                    month: "numeric",
                    year: "numeric"
                }, hideDefaultActions: true},
            {label: 'Is Active', fieldName: 'IsActive', type: 'boolean', initialWidth: 120, hideDefaultActions: true},
            {hideDefaultActions: true, type: 'action', typeAttributes: { rowActions: rowActions }}
        ]);
        helper.fetchData(component);
    },

    handleRowAction: function (component, event, helper) {
        let operation = event.getParam('action');
        let row = event.getParam('row');
        switch (operation.name) {
            case 'groups':
                let action = component.get("c.getAllGroups");
                action.setParams({
                    "userId": row.Id
                });

                action.setCallback(this, function (response) {
                    let state = response.getState();
                    if (state === "SUCCESS") {
                        let groupWrapper = [];
                        let groups = response.getReturnValue();
                        for (let group of groups) {
                            groupWrapper.push({
                                Id: group.Id,
                                Group: group.Group.Name
                            });
                        }

                        let modalBody;
                        $A.createComponents(
                            [
                                ["c:GroupsModal",{
                                    groups : groupWrapper
                                }]
                            ],
                            function(content, status) {
                                if (status === "SUCCESS") {
                                    modalBody = content[0];
                                    component.find('overlayLib').showCustomModal({
                                        header: "User Groups",
                                        body: modalBody,
                                        showCloseButton: true
                                    })
                                }
                            }
                        );
                    }
                });
                $A.enqueueAction(action);
                break;
            case 'login':
                let action2 = component.get("c.getLoginHistories");
                action2.setParams({
                    "userId": row.Id
                });

                action2.setCallback(this, function (response) {
                    let state = response.getState();
                    if (state === "SUCCESS") {
                        let loginHistory = response.getReturnValue();

                        let modalBody;
                        $A.createComponents(
                            [
                                ["c:LoginModal",{
                                    history : loginHistory
                                }]
                            ],
                            function(content, status) {
                                if (status === "SUCCESS") {
                                    modalBody = content[0];
                                    component.find('overlayLib').showCustomModal({
                                        header: "Login History",
                                        body: modalBody,
                                        showCloseButton: true
                                    })
                                }
                            }
                        );
                    }
                });

                $A.enqueueAction(action2);
                break;
        }
    },
})