require("ehr/triggers").initScript(this);

var triggerHelper = new org.labkey.onprc_ehr.query.ONPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);
var console = require("console");

EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.COMPLETE, 'onprc_ehr', 'vet_assignment', function(event, helper){
    console.log('Complete is called!');
    // NOTE: the rules behind vet assignment are complicated enough that any change to one row here could
    // impact a lot of records. Therefore, just redo everything in the cache
    triggerHelper.recalculateAllVetAssignmentRecords()
});