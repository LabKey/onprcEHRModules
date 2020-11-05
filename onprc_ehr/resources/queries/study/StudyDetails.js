/*
 * Copyright (c) 2010-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);
var ONPRC_triggerHelper = new org.labkey.onprc_ehr.query.ONPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

//Added by Kolli on 3/3/2020. This function automatically sets the study details endDate if previous study details endDate is empty when a new study is created.
function onComplete(event, errors, triggerHelper){
    if (!triggerHelper.isETL() && !triggerHelper.isValidateOnly()){
        var studyRows = triggerHelper.getRows();
        var idsToClose = [];
        if (studyRows){
            for (var i=0;i<studyRows.length;i++){
                if (studyRows[i].row.date){
                    idsToClose.push({
                        Id: studyRows[i].row.Id,
                        date: EHR.Server.Utils.datetimeToString(studyRows[i].row.date),  //stringify to serialize properly
                        objectid: studyRows[i].row.objectid
                    });
                }
            }
        }

        if (idsToClose.length){
            //NOTE: this list should be limited to 1 row per animalId
            ONPRC_triggerHelper.closeStudyDetailsRecords(idsToClose);
        }
    }
}