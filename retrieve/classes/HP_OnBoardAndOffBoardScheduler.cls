global class HP_OnBoardAndOffBoardScheduler implements Schedulable {

    global void execute (SchedulableContext sc) {
        HP_OnBoardingBatch onBoardingBatch = new HP_OnBoardingBatch();
        HP_OffBoardingBatch offBoardingBatch = new HP_OffBoardingBatch();
        Database.executeBatch(onBoardingBatch);
        Database.executeBatch(offBoardingBatch);
    }
}