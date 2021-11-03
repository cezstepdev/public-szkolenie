({
    doInit: function (component, event) {
        let item = component.get("v.item");
        component.set("v.itemListSize", item.length);
        let pagesCount = Math.ceil(item.length / 10);
        component.set("v.pagesCount", pagesCount);
        this.reloadItems(component);
    },

    reloadItems: function (component) {
        let page = component.get("v.page");
        let start = (page - 1) * 10;
        let items = component.get("v.item");
        let itemsToShow = [];
        let itemListSize = component.get("v.itemListSize");
        for(let i = 0; i < 10; i++) {
            if(start < itemListSize) {
                component.set("v.disableNext", false);
                component.set("v.disableLast", false);
                if(start >= 0) {
                    itemsToShow.push(items[start]);
                    start++;
                }
                if(page > 1) {
                    component.set("v.disablePrev", false);
                    component.set("v.disableFirst", false);
                }
                else {
                    component.set("v.disablePrev", true);
                    component.set("v.disableFirst", true);
                }
                component.set("v.itemToDisplay", itemsToShow);
            }
            else {
                component.set("v.disableNext", true);
                component.set("v.disableLast", true);
            }
        }
        if((page * 10) === itemListSize) {
            component.set("v.disableNext", true);
            component.set("v.disableLast", true);
        }
    },
})