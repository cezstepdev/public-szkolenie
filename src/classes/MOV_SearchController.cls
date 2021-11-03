public with sharing class MOV_SearchController {

    @AuraEnabled
    public static List<MovieDTO> getMovies(String title) {
        title = title.replaceAll(' ', '%20');
        List<MovieDTO> movieDTOS = new List<MovieDTO>();
        List<MovieDTO> moviesDTOSFromOrg = convertMovieFromCustomToDTO(searchMovieInORG(title));
        movieDTOS.addAll(moviesDTOSFromOrg);
        List<MovieTMDB> movieTMDBS = searchMoviesInTMDB(title);
        for (MovieTMDB movieTMDB : movieTMDBS) {
            List<MovieDTO> movieDTOSFromTMDB = convertMovieFromTMDBToDTO(movieTMDB);
            movieDTOS.addAll(movieDTOSFromTMDB);
        }

        return movieDTOS;
    }

    public static List<String> getDislikedIds() {
        List<MovieDTO> disliked = MOV_RatingController.getDislikedMovies();
        List<String> dislikedIds = new List<String>();
        for (MovieDTO movieDTO : disliked) {
            dislikedIds.add(movieDTO.id);
        }
        return dislikedIds;
    }

    private static List<Movie__c> searchMovieInORG(String title) {
        String condition = '%' + title + '%';

        return [
                SELECT
                        Id,
                        Description__c,
                        Image__c,
                        Title__c
                FROM Movie__c
                WHERE Title__c LIKE :condition
                AND Approval_Status__c = 'Approved'
        ];
    }

    private static List<MovieTMDB> searchMoviesInTMDB(String title) {
        List<MovieTMDB> moviesTMDB = new List<MovieTMDB>();
        Integer page = 1;
        while(true) {
            MovieTMDB movieTMDB = searchMovieInTMDB(title, page);
            moviesTMDB.add(movieTMDB);
            if(movieTMDB.total_pages == page || page == 10) {
                break;
            }
            page++;
        }
        return moviesTMDB;
    }

    private static MovieTMDB searchMovieInTMDB(String title, Integer page) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.themoviedb.org/3/search/movie?api_key=8a51405669d35675375a6b8bb8aab44c&query=' + title + '&page=' + page);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return (MovieTMDB) JSON.deserialize(response.getBody(), MovieTMDB.class);
    }
    
    private static List<MovieDTO> convertMovieFromCustomToDTO(List<Movie__c> movies) {
        List<MovieDTO> movieDTOS = new List<MovieDTO>();
        List<String> dislikedIds = getDislikedIds();

        for (Movie__c movie : movies) {
            MovieDTO movieDTO = new MovieDTO();

            if(dislikedIds.contains(movie.Id)) {
                continue;
            }
            movieDTO.id = movie.Id;
            movieDTO.title = movie.Title__c;
            movieDTO.image = movie.Image__c;
            movieDTO.description = movie.Description__c;
            if(movie.Image__c == null) {
                movieDTO.image = 'http://simpleicon.com/wp-content/uploads/movie-3.png';
            }

            movieDTOS.add(movieDTO);
        }
        return movieDTOS;
    }

    private static List<MovieDTO> convertMovieFromTMDBToDTO(MovieTMDB movies) {
        List<MovieDTO> movieDTOS = new List<MovieDTO>();
        List<String> dislikedIds = getDislikedIds();

        for (MovieItem movie : movies.results) {
            MovieDTO movieDTO = new MovieDTO();

            if(dislikedIds.contains(movie.Id)) {
                continue;
            }

            movieDTO.id = movie.id;
            movieDTO.title = movie.original_title;
            movieDTO.image = 'https://image.tmdb.org/t/p/original' + movie.poster_path;
            if(movie.poster_path == null) {
                movieDTO.image = 'http://simpleicon.com/wp-content/uploads/movie-3.png';
            }
            movieDTO.description = movie.overview;
            movieDTO.releaseDate = movie.release_date;

            movieDTOS.add(movieDTO);
        }
        return movieDTOS;
    }

    @AuraEnabled
    public static List<MOV_ActorSearchController.ActorDTO> getCast(String id) {
        List<MOV_ActorSearchController.ActorDTO> actorDTOS = new List<MOV_ActorSearchController.ActorDTO>();
        if(id.length() < 15) {
            actorDTOS.addAll(getActorsFromTMDB(id));
        }
        else {
            actorDTOS.addAll(getActorsFromORG(id));
        }
        return actorDTOS;
    }

    private static List<MOV_ActorSearchController.ActorDTO> getActorsFromORG(String id) {
        List<MOV_ActorSearchController.ActorDTO> actors = new List<MOV_ActorSearchController.ActorDTO>();
        List<Cast__c> casts = [
                SELECT
                        Actor__r.Id,
                        Character__c,
                        Actor__r.Image__c
                FROM Cast__c
                WHERE Movie__r.Id = :id
        ];

        for (Cast__c movie : casts) {
            MOV_ActorSearchController.ActorDTO actorDTO = new MOV_ActorSearchController.ActorDTO();
            actorDTO.id = movie.Actor__r.Id;
            actorDTO.name = movie.Character__c;
            actorDTO.image = movie.Actor__r.Image__c;
            actors.add(actorDTO);
        }
        return actors;
    }

    private static List<MOV_ActorSearchController.ActorDTO> getActorsFromTMDB(String id) {
        List<MOV_ActorSearchController.ActorDTO> actorDTOS = new List<MOV_ActorSearchController.ActorDTO>();
        CastTMDB result = searchCastInTMDB(id);
        for (MOV_ActorSearchController.ActorItem actorItem : result.castResult) {
            MOV_ActorSearchController.ActorDTO actorDTO = new MOV_ActorSearchController.ActorDTO();
            actorDTO.id = actorItem.id;
            actorDTO.image = 'https://image.tmdb.org/t/p/original' + actorItem.profile_path;
            if(actorItem.profile_path == null) {
                actorDTO.image = 'https://icons-for-free.com/iconfiles/png/512/person-1324760545186718018.png';
            }
            actorDTO.name = actorItem.character;
            if(actorItem.character == '') {
                actorDTO.name = actorItem.name;
            }
            actorDTOS.add(actorDTO);
        }
        return actorDTOS;
    }

    private static CastTMDB searchCastInTMDB(String id) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.themoviedb.org/3/movie/' + id + '/credits?api_key=8a51405669d35675375a6b8bb8aab44c');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return (CastTMDB) JSON.deserialize(response.getBody().replace('"cast"','"castResult"'), CastTMDB.class);
    }

    private static MovieItem getMovieDetailsFromTMDB(String id) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.themoviedb.org/3/movie/' + id + '?api_key=8a51405669d35675375a6b8bb8aab44c');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return (MovieItem) JSON.deserialize(response.getBody(), MovieItem.class);
    }

    public static MovieDTO getMovieDetailsDTOFromTMDB(String id) {
        MovieItem movie = getMovieDetailsFromTMDB(id);
        MovieDTO movieDTO = new MovieDTO();
        movieDTO.id = movie.id;
        movieDTO.title = movie.original_title;
        movieDTO.image = 'https://image.tmdb.org/t/p/original' + movie.poster_path;
        if(movie.poster_path == null) {
            movieDTO.image = 'http://simpleicon.com/wp-content/uploads/movie-3.png';
        }
        movieDTO.description = movie.overview;
        movieDTO.releaseDate = movie.release_date;
        movieDTO.budget = movie.budget;
        return movieDTO;
    }

    private static MovieDTO getMovieDetailsDTOFromORG(String id) {
        Movie__c movie =  [
                SELECT
                        Id,
                        Title__c,
                        Image__c,
                        Description__c,
                        ReleaseDate__c,
                        Approval_Status__c,
                        Budget__c
                FROM Movie__c
                WHERE Id = :id
        ];
        MovieDTO movieDTO = new MovieDTO();
        movieDTO.id = movie.id;
        movieDTO.title = movie.Title__c;
        movieDTO.image = movie.Image__c;
        if(movie.Image__c == null) {
            movieDTO.image = 'http://simpleicon.com/wp-content/uploads/movie-3.png';
        }
        movieDTO.description = movie.Description__c;
        movieDTO.releaseDate = String.valueOf(movie.ReleaseDate__c);
        movieDTO.budget = movie.Budget__c;
        movieDTO.status = movie.Approval_Status__c;
        return movieDTO;
    }

    private static List<String> getFavFilms() {
        String userId = UserInfo.getUserId();

        List<Favourite__c> favourites = [
                SELECT
                        Movie__c,
                        movieId__c
                FROM Favourite__c
                WHERE CreatedBy.Id = :userId
        ];
        List<String> liked = new List<String>();
        for (Favourite__c favourite : favourites) {
            liked.add(favourite.movieId__c);
        }

        return liked;
    }

    private static List<String> getDislikedFilms() {
        String userId = UserInfo.getUserId();

        List<DislikedMovie__c> dislikedMovies = [
                SELECT
                        movieId__c
                FROM DislikedMovie__c
                WHERE CreatedBy.Id = :userId
        ];
        List<String> liked = new List<String>();
        for (DislikedMovie__c disliked : dislikedMovies) {
            liked.add(disliked.movieId__c);
        }
        return liked;
    }

    @AuraEnabled
    public static MovieDTO getMovieDetails(String id) {
        MovieDTO movieDTO;
        if(id.length() < 15) {
            movieDTO = getMovieDetailsDTOFromTMDB(id);
        }
        else {
            movieDTO = getMovieDetailsDTOFromORG(id);
        }
        List<String> liked = getFavFilms();
        List<String> disliked = getDislikedFilms();
        if(liked.contains(id)) {
            movieDTO.favourite = true;
        } else {
            movieDTO.favourite = false;
        }

        if(disliked.contains(id)) {
            movieDTO.disliked = true;
        } else {
            movieDTO.disliked = false;
        }
        return movieDTO;
    }

    public class MovieDTO {
        @auraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String image {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String releaseDate {get; set;}
        @AuraEnabled
        public Boolean favourite {get; set;}
        @AuraEnabled
        public Boolean disliked {get; set;}
        @AuraEnabled
        public String budget {get; set;}
        @AuraEnabled
        public String status {get; set;}

        public MovieDTO() {

        }

        public MovieDTO(String title, String image, String description) {
            this.title = title;
            this.image = image;
            this.description = description;
        }
    }

    public class MovieTMDB {
        @AuraEnabled
        public List<MovieItem> results {get; set;}
        @AuraEnabled
        public Integer total_pages {get; set;}
    }

    public class MovieItem {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String original_title {get; set;}
        @AuraEnabled
        public String overview {get; set;}
        @AuraEnabled
        Public String poster_path {get; set;}
        @AuraEnabled
        Public String release_date {get; set;}
        @AuraEnabled
        Public String budget {get; set;}
    }

    public class CastTMDB {
        @AuraEnabled
        public List<MOV_ActorSearchController.ActorItem> castResult {get; set;}
    }
}