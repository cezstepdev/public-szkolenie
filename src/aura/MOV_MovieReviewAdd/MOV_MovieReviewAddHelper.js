({
    doInit: function (component) {
        component.find("service").getNewRecord(
            "MovieReview__c", // sObject type (entityAPIName)
            null,            // recordTypeId
            false,           // skip cache?
            $A.getCallback( function() {
                let rec=component.get("v.simpleMovieReview");
                let error=component.get("v.recordError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    component.set("v.movieReview.movieId__c", component.get("v.movie.id"));
                    component.set("v.movieReview.Rating__c", 0);
                }
            })
        );
    }
})