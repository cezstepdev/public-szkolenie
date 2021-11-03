({
    doInit: function (component, event) {
        component.set('v.center', {
            location: {
                City: 'Lisbona'
            }
        });

        component.set('v.zoomLevel', 2);
        component.set('v.listView', "hidden");
    }
})