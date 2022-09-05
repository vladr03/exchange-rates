global class ExchangeRatesSchedule implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext sc) {
        ExchangeRateCallout.createExchangeRate('GBP', Date.today());
    }
}