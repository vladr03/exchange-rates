global class ChangingBaseCurrency implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    List<Exchange_Rate__c> erList = new List<Exchange_Rate__c>();
    private String baseCurrency;
    public ChangingBaseCurrency(String base) {
        baseCurrency = base;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Date__c, Base_Currency__c FROM Exchange_Rate__c';       
        return Database.getQueryLocator(query);
    }    
    
    global void execute(Database.BatchableContext bc, List<Exchange_Rate__c> records){
        System.debug('check base ' + baseCurrency); 
        System.debug('records '+ records);
        for(Exchange_Rate__c er: records) {
            er.Base_Currency__c = baseCurrency;
            String url_str = 'https://api.exchangerate.host/' + String.valueOf(er.Date__c).removeEnd(' 00:00:00') + '?base=' + er.Base_Currency__c;
            System.debug('url: ' + url_str);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url_str);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            JSON2Apex des = JSON2Apex.parse(res.getBody());
            er.Base_Currency__c = des.base;
            er.Date__c = des.date_X;
            er.CAD__c = des.rates.CAD;
            er.EUR__c = des.rates.EUR;         
            er.GBP__c = des.rates.GBP;
            er.USD__c = des.rates.USD;
            erList.add(er);
        }                        
        update erList;
        String jsonString = JSON.serializePretty(erList);
        
    }
    
    global void finish(Database.BatchableContext bc) {}
}
