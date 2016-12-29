/*
 * Copyright (c) 2010-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 * Created: L.Kolli
 * Date: 10/3/2016
 */

require("ehr/triggers").initScript(this);
var triggerHelper = new org.labkey.onprc_ehr.query.ONPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

function onInit(event, helper){
    helper.setScriptOptions({
        allowAnyId: true,
        requiresStatusRecalc: true


    });
}

EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Arrival', function(scriptErrors, helper, row, oldRow) {
    helper.registerArrival(row.Id, row.date);

    //if not already present, we insert into demographics
    if (!helper.isETL() && !helper.isGeneratedByServer()){
        //helper.getJavaHelper().onAnimalArrival_ONPRC(row.id, row);

        //Add Demographics record
        helper.getJavaHelper().createDemographicsRecord(row.Id, triggerHelper.onAnimalArrival_AddDemographics(row.id, row));

        //Add Birth record
        triggerHelper.onAnimalArrival_AddBirth(row.id, row);

        //Add Housing record if room provided
        if (row.initialRoom){
            helper.getJavaHelper().createHousingRecord(row.Id, row.date, null, row.initialRoom, (row.initialCage || null), null);
        }
    }
});