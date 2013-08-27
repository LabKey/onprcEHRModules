/*
 * Copyright (c) 2012-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onUpsert(helper, scriptErrors, row, oldRow){
    if (helper.isETL())
        return;

    if (row.aggressor){
        if (row.aggressor != row.Id && row.aggressor != row.id2){
            EHR.Server.Utils.addError(scriptErrors, 'aggressor', 'The aggresor must match one of the two IDs', 'ERROR');
        }
    }

    if (row.Id && row.date && row.room1){
        if (!helper.getJavaHelper().validateHousing(row.Id, row.room1, row.cage1, row.date)){
            EHR.Server.Utils.addError(scriptErrors, 'room1', 'The first animal is not housed in this location on the date provided', 'ERROR');
        }
    }

    if (row.Id2 && row.date && row.room2){
        if (!helper.getJavaHelper().validateHousing(row.Id2, row.room2, row.cage2, row.date)){
            EHR.Server.Utils.addError(scriptErrors, 'room2', 'The first animal is not housed in this location on the date provided', 'ERROR');
        }
    }

    if (row.room1 && row.room1 != row.room2){
        EHR.Server.Utils.addError(scriptErrors, 'room1', 'The two rooms must match', 'WARN');
        EHR.Server.Utils.addError(scriptErrors, 'room2', 'The two rooms must match', 'WARN');
    }

    EHR.Server.Validation.validateAnimal(helper, scriptErrors, row, 'Id2');
}