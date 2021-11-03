public with sharing class MOV_MyMoviesController {
    @AuraEnabled
    public static List<MOV_SearchController.MovieDTO> getMyMovies() {
        System.debug('siema');
        String userId = UserInfo.getUserId();

        List<Movie__c> myMovies = [
                SELECT
                        Id,
                        Image__c,
                        Title__c,
                        Approval_Status__c
                FROM Movie__c
                WHERE CreatedBy.Id = :userId
        ];

        List<MOV_SearchController.MovieDTO> movieDTOS = new List<MOV_SearchController.MovieDTO>();
        for (Movie__c movie : myMovies) {
            MOV_SearchController.MovieDTO movieDTO = new MOV_SearchController.MovieDTO();
            movieDTO.id = movie.Id;
            movieDTO.title = movie.Title__c;
            movieDTO.image = movie.Image__c;
            if(movie.Image__c == null) {
                movieDTO.image = 'http://simpleicon.com/wp-content/uploads/movie-3.png';
            }
            movieDTO.status = movie.Approval_Status__c;
            movieDTOS.add(movieDTO);
        }
        return movieDTOS;
    }
}