/**
 * Created by BRITENET on 20.08.2021.
 */

public with sharing class QueueableExceed implements Queueable {
    public void execute(QueueableContext context) {
        Account a = new Account(Name='Acme',Phone='(415) 555-1212');
        insert a;
    }
}