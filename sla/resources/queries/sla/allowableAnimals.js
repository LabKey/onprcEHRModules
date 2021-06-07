// var console = require("console");
// var LABKEY = require("labkey");
//
//
// function beforeInsert(row, errors){
//     row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
// }

var console = require("console");
var LABKEY = require("labkey");

require("ehr/triggers").initScript(this);
var triggerHelper = new org.labkey.onprc_ehr.query.ONPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

function beforeInsert(row, errors){
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
}

//Validate dates. Kollil, 1/19/2021
EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'sla', 'allowableAnimals', function(helper, scriptErrors, row, oldRow)
{
    var start = row.startdate;
    var end = row.enddate;
    //console.log ("In 1");

    // Check if startdate and enddate are not empty
    if ((start == null && end == null) || (start == null && end != null) || (start != null && end == null)) {
        EHR.Server.Utils.addError(scriptErrors, 'startdate', 'Must enter Start and End dates', 'ERROR');
    }

    //enddate: verify enddate not prior to startdate
    if (start != null  && end != null) {
        if (start.getTime() > end.getTime()) {
            EHR.Server.Utils.addError(scriptErrors, 'enddate', 'End date must be after the Start date', 'ERROR');
        }
    }

});
