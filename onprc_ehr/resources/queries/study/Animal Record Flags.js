/*
 * Copyright (c) 2012-2013 LabKey Corporation
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