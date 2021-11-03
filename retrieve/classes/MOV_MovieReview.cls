public with sharing class MOV_MovieReview {
    @AuraEnabled
    public static List<MovieReview__c> getAll (String id) {
        List<MovieReview__c> movieReviews = [
                SELECT
                        Comment__c,
                        CreatedById,
                        CreatedDate,
                        Id,
                        IsDeleted,
                        LastModifiedById,
                        LastModifiedDate,
                        Name,
                        OwnerId,
                        Rating__c,
                        movieId__c,
                        SystemModstamp,
                        CreatedBy.Name
                FROM MovieReview__c
                WHERE movieId__c = :id
        ];
        return movieReviews;
    }
}