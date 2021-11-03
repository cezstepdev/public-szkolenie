({
    onRowClick: function (component, event, helper) {
        let accountList = component.get("v.accounts");
        let account = accountList.find(account => account.Id === event.currentTarget.dataset.id);
        component.set("v.selectedAccountId", account.Id);

        let selectUserEvent = $A.get("e.c:AccountSelect");
        selectUserEvent.setParams(
            {
                selectedAccount: account
            }
        );
        selectUserEvent.fire();
    },

    reloadAccount: function (component, event) {
        let accountList = component.get("v.accounts");
        let account = accountList.find(account => account.Id === event.getParam("accountId"));

        let selectUserEvent = $A.get("e.c:AccountSelect");
        selectUserEvent.setParams(
            {
                selectedAccount: account
            }
        );
        selectUserEvent.fire();
    },

    onAccountGet: function (component, event, helper) {
        let receivedList = event.getParam("objectList");
        component.set("v.accounts", receivedList);

        component.set("v.selectedAccountId", undefined);

        let selectUserEvent = $A.get("e.c:AccountSelect");
        selectUserEvent.setParams(
            {
                selectedAccount: null
            }
        );
        selectUserEvent.fire();
    }
})