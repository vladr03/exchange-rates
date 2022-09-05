global with sharing class ExchangeRateCallout {

    @AuraEnabled
    public static void createExchangeRate(String baseCurrency, Date userDate) {
        //String url_str = 'https://api.exchangerate.host/latest?base=' + baseCurrency;
        String url_str = 'https://api.exchangerate.host/' + String.valueOf(userDate).removeEnd(' 00:00:00') + '?base=' + baseCurrency;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url_str);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //create Log__c
        Log__c l = new Log__c();
        l.Response_Body__c = res.getBody();
        l.Status_Code__c = res.getStatus();
        insert l;
        JSON2Apex des = JSON2Apex.parse(res.getBody());
        //create Exchange_Rate__c
        Exchange_Rate__c er = new Exchange_Rate__c();
        er.Base_Currency__c = des.base;
        er.Date__c = des.date_X;
        er.CAD__c = des.rates.CAD;
        er.EUR__c = des.rates.EUR;
        er.GBP__c = des.rates.GBP;
        er.USD__c = des.rates.USD;
        er.Log__c = l.Id;
        insert er;
    }

    @AuraEnabled
    public static void callingBatch(String base) 
    { 
        System.debug('base ' + base);
        ChangingBaseCurrency cbc = new ChangingBaseCurrency(base); 
        Database.executeBatch(cbc); 
    } 

    @AuraEnabled 
    public static Map<String, String> getBaseCurrency(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Exchange_Rate__c.Base_Currency__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<Exchange_Rate__c> getExchangeRate(Date dateSelected)
    {
        List<Exchange_Rate__c> ratesList = [SELECT Date__C, CAD__c, EUR__c, GBP__c, USD__c FROM Exchange_Rate__c WHERE Date__c = :dateSelected];
        return ratesList;
    } 
}
