({
    doInit: function(component, event, helper) {
        if(component.get("v.item.favourite") !== undefined) {
            component.set("v.liked", component.get("v.item.favourite"));
        }

        if(component.get("v.item.disliked") !== undefined) {
            component.set("v.disliked", component.get("v.item.disliked"));
        }
    },

    handleLikeButtonClick : function (component) {
        let action;
        if(component.get('v.liked')) {
            action = component.get("c.removeFromFavourite");
        } else {
            action = component.get("c.addToFavourite");
        }

        action.setParams(
            {
                id: component.get("v.item.id"),
                title: component.get("v.item.title"),
                image: component.get("v.item.image")
            }
        );

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.liked', !component.get('v.liked'));
            }
        });

        $A.enqueueAction(action);
    },

    handleDislikeButtonClick : function (component) {
        let action;
        if(component.get('v.disliked')) {
            action = component.get("c.removeFromDisliked");
        } else {
            action = component.get("c.addToDisliked");
        }

        action.setParams(
            {
                id: component.get("v.item.id"),
                title: component.get("v.item.title"),
                image: component.get("v.item.image")
            }
        );

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.disliked', !component.get('v.disliked'));
            }
        });

        $A.enqueueAction(action);
    },
})