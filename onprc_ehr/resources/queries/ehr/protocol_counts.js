/*
 * Copyright (c) 2011-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onUpsert(helper, scriptErrors, row, oldRow){
    if (row && row.project){
        EHR.Server.Utils.addError(scriptErrors, 'project', 'You should probably leave this field blank.  Animal counts are usually associated with the IACUC itself.  The project field was left in place to support IRIS data, but should not be used unless there is a good reason to do so.', 'INFO');
    }
}
//Validate dates. Kollil, 1/19/2021
EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'protocol_counts', function(helper, scriptErrors, row, oldRow)
{
    var start = row.start;
    var end = row.enddate;
    //console.log ("In 11");

    // Check if startdate and enddate are not empty
    if ((start == null && end == null) || (start == null && end != null) || (start != null && end == null)) {
        EHR.Server.Utils.addError(scriptErrors, 'start', 'Must enter Start and End dates', 'ERROR');
    }

    //enddate: verify enddate not prior to startdate
    if (start != null  && end != null) {
        if (start.getTime() > end.getTime()) {
            EHR.Server.Utils.addError(scriptErrors, 'enddate', 'End date must be after Start date', 'ERROR');
        }
    }

});