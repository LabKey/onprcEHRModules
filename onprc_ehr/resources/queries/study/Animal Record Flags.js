/*
 * Copyright (c) 2012-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onUpsert(helper, scriptErrors, row, oldRow){
    //if the animal is not at the center, automatically set the enddate
    if (!helper.isETL() && row.Id && !row.enddate){
        EHR.Server.Utils.findDemographics({
            participant: row.Id,
            helper: helper,
            scope: this,
            callback: function(data){
                if (!data)
                    return;

                if (data && data.calculated_status && data.calculated_status != 'Alive'){
                    row.enddate = data.death || data.departure;
                }
            }
        });

    }
}

function onAfterInsert(helper, errors, row){
    //if this category enforces only a single active flag at once, enforce it
    if (!helper.isETL() && row.Id && row.category && !row.enddate && row.date && row.date.getTime() <= (new Date()).getTime()){
        helper.getJavaHelper().ensureSingleFlagCategoryActive(row.Id, row.category, row.objectId, row.date);
    }
}