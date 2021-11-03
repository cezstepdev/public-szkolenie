public with sharing class MOV_ActorSearchController {

    @AuraEnabled
    public static List<ActorDTO> getActors(String name, Integer page) {
        name = name.replaceAll(' ', '%20');
        List<ActorDTO> actorDTOS = new List<ActorDTO>();
        List<ActorDTO> actorDTOSFromOrg = convertActorFromCustomToDTO(searchActorInORG(name));
        actorDTOS.addAll(actorDTOSFromOrg);
        List<ActorTMDB> actorTMDBS = searchActorsInTMDB(name);
        for (ActorTMDB actorTMDB : actorTMDBS) {
            List<ActorDTO> actorDTOSFromTMDB = convertActorFromTMDBToDTO(actorTMDB);
            actorDTOS.addAll(actorDTOSFromTMDB);
        }
        return actorDTOS;
    }

    private static List<Actor__c> searchActorInORG(String name) {
        String condition = '%' + name + '%';

        return [
                SELECT
                        Id,
                        Name,
                        Image__c
                FROM Actor__c
                WHERE Name LIKE :condition
        ];
    }

    private static List<ActorTMDB> searchActorsInTMDB(String name) {
        List<ActorTMDB> actorsTMDB = new List<ActorTMDB>();
        Integer page = 1;
        while(true) {
            ActorTMDB actorTMDB = searchActorInTMDB(name, page);
            actorsTMDB.add(actorTMDB);
            if(actorTMDB.total_pages == page || page == 10) {
                break;
            }
            page++;
        }
        return actorsTMDB;
    }

    private static ActorTMDB searchActorInTMDB(String name, Integer page) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.themoviedb.org/3/search/person?api_key=8a51405669d35675375a6b8bb8aab44c&query=' + name + '&page=' + page);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return (ActorTMDB) JSON.deserialize(response.getBody(), ActorTMDB.class);
    }

    private static List<ActorDTO> convertActorFromCustomToDTO(List<Actor__c> actors) {
        List<ActorDTO> actorDTOS = new List<ActorDTO>();

        for (Actor__c actor : actors) {
            ActorDTO actorDTO = new ActorDTO();
            actorDTO.id = actor.Id;
            actorDTO.name = actor.Name;
            actorDTO.image = actor.Image__c;

            actorDTOS.add(actorDTO);
        }
        return actorDTOS;
    }

    private static List<ActorDTO> convertActorFromTMDBToDTO(ActorTMDB actors) {
        List<ActorDTO> actorDTOS = new List<ActorDTO>();

        for (ActorItem actor : actors.results) {
            actorDTO actorDTO = new ActorDTO();

            actorDTO.id = actor.id;
            actorDTO.name = actor.name;
            actorDTO.image = 'https://image.tmdb.org/t/p/original' + actor.profile_path;
            if(actor.profile_path == null) {
                actorDTO.image = 'https://icons-for-free.com/iconfiles/png/512/person-1324760545186718018.png';
            }
            actorDTOS.add(actorDTO);
        }
        return actorDTOS;
    }

    @AuraEnabled
    public static List<MOV_SearchController.MovieDTO> getMovies(String id) {
        List<MOV_SearchController.MovieDTO> movies = new List<MOV_SearchController.MovieDTO>();
        if(id.length() < 15) {
            movies.addAll(getMoviesFromTMDB(id));
        }
        else {
            movies.addAll(getMoviesFromORG(id));
        }
        return movies;
    }

    private static List<MOV_SearchController.MovieDTO> getMoviesFromORG(String id) {
        List<MOV_SearchController.MovieDTO> movies = new List<MOV_SearchController.MovieDTO>();
        List<String> dislikedIds = MOV_SearchController.getDislikedIds();

        List<Cast__c> casts = [
                SELECT
                        Movie__r.id,
                        Movie__r.Name,
                        Movie__r.Image__c
                FROM Cast__c
                WHERE Actor__r.Id = :id
                AND Movie__r.Approval_Status__c = 'Approved'
        ];

        for (Cast__c movie : casts) {
            if(dislikedIds.contains(movie.Movie__r.Id)) {
                continue;
            }
            MOV_SearchController.MovieDTO movieDTO = new MOV_SearchController.MovieDTO();
            movieDTO.id = movie.Movie__r.Id;
            movieDTO.title = movie.Movie__r.Name;
            movieDTO.image = movie.Movie__r.Image__c;
            movies.add(movieDTO);
        }
        return movies;
    }

    private static List<MOV_SearchController.MovieDTO> getMoviesFromTMDB(String id) {
        List<MOV_SearchController.MovieDTO> movies = new List<MOV_SearchController.MovieDTO>();
        List<String> dislikedIds = MOV_SearchController.getDislikedIds();
        MovieResult moviesResult = searchMovieInTMDB(id);
        for(MOV_SearchController.MovieItem movie : moviesResult.castResult) {
            if(dislikedIds.contains(movie.id)) {
                continue;
            }
            MOV_SearchController.MovieDTO movieDTO = new MOV_SearchController.MovieDTO();
            movieDTO.id = movie.id;
            movieDTO.title = movie.original_title;
            movieDTO.image = 'https://image.tmdb.org/t/p/original' + movie.poster_path;
            if(movie.poster_path == null) {
                movieDTO.image = 'http://simpleicon.com/wp-content/uploads/movie-3.png';
            }
            if(movieDTO.title != null) {
                movies.add(movieDTO);
            }
        }
        return movies;
    }

    private static MovieResult searchMovieInTMDB(String id) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.themoviedb.org/3/person/' + id + '/movie_credits?api_key=8a51405669d35675375a6b8bb8aab44c');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return (MovieResult) JSON.deserialize(response.getBody().replace('"cast"','"castResult"'), MovieResult.class);
    }

    private static ActorItem getActorDetailsFromTMDB(String id) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.themoviedb.org/3/person/' + id + '?api_key=8a51405669d35675375a6b8bb8aab44c');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return (ActorItem) JSON.deserialize(response.getBody(), ActorItem.class);
    }

    private static ActorDTO getActorDetailsFromORG(String id) {
        Actor__c actor =  [
                SELECT
                        Id,
                        Name,
                        Image__c,
                        Biography__c,
                        Birthday__c,
                        PlaceOfBirth__c
                FROM Actor__c
                WHERE Id = :id
        ];
        ActorDTO actorDTO = new ActorDTO();
        actorDTO.id = actor.id;
        actorDTO.name = actor.Name;
        actorDTO.image = actor.Image__c;
        actorDTO.biography = actor.Biography__c;
        actorDTO.birthday = String.valueOf(actor.Birthday__c);
        actorDTO.place_of_birth = actor.PlaceOfBirth__c;
        return actorDTO;
    }

    @AuraEnabled
    public static ActorDTO getActorDetails(String id) {
        if(id.length() < 15) {
            ActorItem actor = getActorDetailsFromTMDB(id);
            ActorDTO actorDTO = new ActorDTO();
            actorDTO.id = actor.id;
            actorDTO.name = actor.name;
            actorDTO.image = 'https://image.tmdb.org/t/p/original' + actor.profile_path;
            if(actor.profile_path == null) {
                actorDTO.image = 'https://icons-for-free.com/iconfiles/png/512/person-1324760545186718018.png';
            }
            actorDTO.birthday = actor.birthday;
            actorDTO.biography = actor.biography;
            actorDTO.place_of_birth = actor.place_of_birth;
            return actorDTO;
        }
        return getActorDetailsFromORG(id);
    }

    public class ActorDTO {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String image {get; set;}
        @AuraEnabled
        public String biography {get; set;}
        @AuraEnabled
        public String birthday {get; set;}
        @AuraEnabled
        public String place_of_birth {get; set;}
        @AuraEnabled
        public List<MOV_SearchController.MovieDTO> movies {get; set;}

        public ActorDTO() {

        }

        public ActorDTO(String name, String image) {
            this.name = name;
            this.image = image;
        }
    }

    public class ActorTMDB {
        @AuraEnabled
        public List<ActorItem> results {get; set;}
        @AuraEnabled
        public Integer total_pages {get; set;}
    }

    public class ActorItem {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        Public String profile_path {get; set;}
        @AuraEnabled
        public String character {get; set;}
        @AuraEnabled
        public String biography {get; set;}
        @AuraEnabled
        public String birthday {get; set;}
        @AuraEnabled
        public String place_of_birth {get; set;}
        @AuraEnabled
        public List<MOV_SearchController.MovieItem> known_for {get; set;}
    }

    public class MovieResult {
        @AuraEnabled
        public List<MOV_SearchController.MovieItem> castResult {get; set;}
    }
}