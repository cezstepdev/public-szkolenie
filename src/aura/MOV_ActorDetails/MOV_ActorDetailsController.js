({
    onSelectedItem: function (component, event, helper) {
        let item = event.getParam("item");
        component.set("v.item", item);
        let movies = event.getParam("movies");
        component.set("v.movies", movies);
    },
})