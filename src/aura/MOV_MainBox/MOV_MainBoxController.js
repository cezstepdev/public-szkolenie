({
    handleActive: function (cmp, event, helper) {
        let movieSendParam = $A.get("e.c:MOV_MovieSelectedItem");
        movieSendParam.setParams(
            {
                item: undefined,
                cast: []
            }
        );
        movieSendParam.fire();

        let actorSendParam = $A.get("e.c:MOV_SelectedItem");
        actorSendParam.setParams(
            {
                item: null,
                movies: []
            }
        );
        actorSendParam.fire();
    }
})