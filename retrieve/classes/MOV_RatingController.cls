public with sharing class MOV_RatingController {
    @AuraEnabled
    public static void addToFavourite(String id, String title, String image) {

        Favourite__c favMovie = new Favourite__c();
        favMovie.movieId__c = id;
        favMovie.Title__c = title;
        favMovie.Image__c = image;
        insert favMovie;
    }

    @AuraEnabled
    public static void addToDisliked(String id, String title, String image) {

        DislikedMovie__c movie = new DislikedMovie__c();
        movie.movieId__c = id;
        movie.Title__c = title;
        movie.Image__c = image;
        insert movie;
    }

    @AuraEnabled
    public static void removeFromFavourite(String id) {
        String userId = UserInfo.getUserId();

        Favourite__c favMovie = [
                SELECT Id
                FROM Favourite__c
                WHERE movieId__c = :id
                AND CreatedBy.Id = :userId
        ];

        delete favMovie;
    }

    @AuraEnabled
    public static void removeFromDisliked(String id) {

        String userId = UserInfo.getUserId();
        DislikedMovie__c favMovie = [
                SELECT Id
                FROM DislikedMovie__c
                WHERE movieId__c = :id
                AND CreatedBy.Id = :userId
        ];

        delete favMovie;
    }

    @AuraEnabled
    public static List<MOV_SearchController.MovieDTO> getLikedMovies() {
        String userId = UserInfo.getUserId();
        List<Favourite__c> liked = [
                SELECT
                        Title__c,
                        Image__c,
                        movieId__c
                FROM Favourite__c
                WHERE CreatedBy.Id = :userId
        ];
        return convertLikedToDTO(liked);
    }

    @AuraEnabled
    public static List<MOV_SearchController.MovieDTO> getDislikedMovies() {
        String userId = UserInfo.getUserId();

        List<DislikedMovie__c> disliked = [
                SELECT
                        Id,
                        Title__c,
                        Image__c,
                        movieId__c
                FROM DislikedMovie__c
                WHERE CreatedBy.Id = :userId
        ];
        return convertDislikedToDTO(disliked);
    }

    @AuraEnabled
    public static Boolean checkReviewExist(String id) {
        String userId = UserInfo.getUserId();

        if([
                SELECT Id
                FROM MovieReview__c
                WHERE CreatedBy.id = :userId
                AND movieId__c = :id
        ].size() > 0) {
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Decimal getAverageRating (String id) {
        Decimal avg = Decimal.valueOf(
                String.valueOf(
                        [
                                SELECT AVG(Rating__c)
                                FROM MovieReview__c
                                WHERE movieId__c = :id
                        ].get(0).get('expr0')
                )
        ).setScale(1);
        return avg;
    }

    @AuraEnabled
    public static String getApprovalInfo(String id) {
        List<ProcessInstanceStep> approvalInfo = [
                SELECT Id, Comments
                FROM ProcessInstanceStep
                WHERE ProcessInstance.TargetObjectId = :id
                ORDER BY CreatedDate DESC
        ];
        String comment = approvalInfo.get(0).Comments;
        return comment;
    }

    private static List<MOV_SearchController.MovieDTO> convertLikedToDTO(List<Favourite__c> liked) {
        List<MOV_SearchController.MovieDTO> movieDTOS = new List<MOV_SearchController.MovieDTO>();
        for (Favourite__c favourite : liked) {
            MOV_SearchController.MovieDTO movieDTO = new MOV_SearchController.MovieDTO();
            movieDTO.id = favourite.movieId__c;
            movieDTO.title = favourite.Title__c;
            movieDTO.image = favourite.Image__c;
            movieDTOS.add(movieDTO);
        }
        return movieDTOS;
    }

    private static List<MOV_SearchController.MovieDTO> convertDislikedToDTO(List<DislikedMovie__c> dislikedMovies) {
        List<MOV_SearchController.MovieDTO> movieDTOS = new List<MOV_SearchController.MovieDTO>();
        for (DislikedMovie__c disliked : dislikedMovies) {
            MOV_SearchController.MovieDTO movieDTO = new MOV_SearchController.MovieDTO();
            movieDTO.id = disliked.movieId__c;
            movieDTO.title = disliked.Title__c;
            movieDTO.image = disliked.Image__c;
            movieDTOS.add(movieDTO);
        }
        return movieDTOS;
    }
}