({
    doInit: function (component, event, helper) {
        helper.doInit(component, event);
    },

    onFirstClick: function (component, event, helper) {
        const spinner = component.find("spinner");
        spinner.showSpinner();
        component.set("v.page", 1);
        helper.reloadItems(component);
    },

    onPrevClick: function (component, event, helper) {
        let page = component.get("v.page");
        page--;
        component.set("v.page", page);
        helper.reloadItems(component);
    },

    onNextClick: function (component, event, helper) {
        let page = component.get("v.page");
        page++;
        component.set("v.page", page);
        helper.reloadItems(component);
    },

    onLastClick: function (component, event, helper) {
        let listSize = component.get("v.itemListSize");
        let page = Math.ceil(listSize/10);
        component.set("v.page", page);
        helper.reloadItems(component);
    },
})