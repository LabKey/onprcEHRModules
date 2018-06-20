/*
 * Copyright (c) 2012-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onInit(event, helper){
    helper.setScriptOptions({
        allowFutureDates: true,
        removeTimeFromDate: true,
        removeTimeFromEndDate: true
    });
}

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

    if (!helper.isETL() && row.Id && row.date && row.flag){
        var active = helper.getJavaHelper().getOverlappingFlags(row.Id, row.flag, row.objectid || null, row.date);
        if (active > 0){
            EHR.Server.Utils.addError(scriptErrors, 'flag', 'There are already ' + active + ' active flag(s) of the same type spanning this date.', 'INFO');
        }
    }
}

function onAfterInsert(helper, errors, row){
    //if this category enforces only a single active flag at once, enforce it
    //note: if this flag has a future date, preemptively set enddate on flags, since isActive should handle this
    if (!helper.isETL() && row.Id && row.flag && !row.enddate && row.date){
        helper.getJavaHelper().ensureSingleFlagCategoryActive(row.Id, row.flag, row.objectId, row.date);
    }
}