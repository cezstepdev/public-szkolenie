({
    fetchData: function (component) {
        let action = component.get("c.getAllUsers");
        action.setCallback(this,function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let users = response.getReturnValue();
                let active = 0;
                let inactive = 0;
                for (let user of users) {
                    if(user.IsActive === true) {
                        active++;
                    }
                    else {
                        inactive++;
                    }
                }
                component.set("v.active", active);
                component.set("v.inactive", inactive);
                component.set('v.data', users);
            }
        });
        $A.enqueueAction(action);
    },

    getRowActions: function (component, row, doneCallback) {
        let actions = [{
            'label': 'Show groups',
            'iconName': 'utility:zoomin',
            'name': 'groups'
        }];

        let loginAction = {
            'label': 'Login history',
            'iconName': 'utility:approval',
            'name': 'login'
        };

        actions.push(loginAction);

        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    }
})