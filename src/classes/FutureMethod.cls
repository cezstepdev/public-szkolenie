/**
 * Created by BRITENET on 20.08.2021.
 */

public with sharing class FutureMethod {
    @future
    public static void futureMethod() {
        System.debug('Test');
    }
}