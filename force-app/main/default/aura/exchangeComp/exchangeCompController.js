({
    doInit: function (component, event, helper) {
        var action = component.get("c.getBaseCurrency");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for (var key in result) {
                    fieldMap.push({ key: key, value: result[key] });
                }
                component.set("v.fieldMap", fieldMap);
            }
        });
        $A.enqueueAction(action);

    },

    changeCurrencyHandler: function (component, event, helper) {
        var action = component.get("c.callingBatch");
        action.setParams({ base: component.get("v.exchangeRate.Base_Currency__c") });
        console.log('111', component.get("v.exchangeRate.Base_Currency__c"));
        $A.enqueueAction(action);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "message": "The Base Currency has been changed."
        });
        toastEvent.fire();
    },

    createHandler: function (component, event, helper) {
        console.log('hello');
        var action = component.get("c.createExchangeRate");
        action.setParams({ baseCurrency: component.get("v.exchangeRate.Base_Currency__c"), userDate:  component.get("v.userDate")});
        $A.enqueueAction(action);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "message": "The Exchange Rate has been created."
        });
        toastEvent.fire();
    },

    handleOnChange: function (component, event, helper) {
        console.log('hello');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "message": "The currency has been changed to " + component.get("v.exchangeRate.Base_Currency__c") + "."
        });
        toastEvent.fire();
    },

    getRecordHandler: function (component, event, helper) {
        let dateChanged = event.getSource();
        component.set("v.userDate",  dateChanged.get("v.value"));
        var action = component.get("c.getExchangeRate");
        action.setParams({ dateSelected: dateChanged.get("v.value") });
        console.log('$$$', dateChanged.get("v.value"));
        action.setCallback(this, function (response) {
            var name = response.getState();
            console.log('$$', name);

            if (name === "SUCCESS") {
                console.log('$', response.getReturnValue());
                component.set("v.records", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})