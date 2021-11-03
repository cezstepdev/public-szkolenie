({
    onImageClick: function (component, event) {
        let modalBody;
        $A.createComponents(
            [
                ["c:MOV_MovieModal",{
                    item : component.get("v.item")
                }]
            ],
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content[0];
                    component.find('overlayLib').showCustomModal({
                        header: "Film information",
                        body: modalBody,
                        showCloseButton: true
                    })
                }
            }
        );
    }
})