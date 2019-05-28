/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onInit(event, helper){
    helper.setScriptOptions({
        skipHousingCheck: true,
        allowFutureDates: true
    });

    helper.decodeExtraContextProperty('housingInTransaction');

    helper.registerRowProcessor(function(helper, row){
        if (!row)
            return;

        if (!row.Id || !row.room){
            return;
        }

        //TODO: this should be moved to common code shared with housing.js
        var housingInTransaction = helper.getProperty('housingInTransaction');
        housingInTransaction = housingInTransaction || {};
        housingInTransaction[row.Id] = housingInTransaction[row.Id] || [];

        // this is a failsafe in case the client did not provide housing JSON.  it ensures
        // the current row is part of housingInTransaction
        var shouldAdd = true;
        if (row.objectid){
            LABKEY.ExtAdapter.each(housingInTransaction[row.Id], function(r){
                if (r.objectid == row.objectid){
                    shouldAdd = false;
                    return false;
                }
            }, this);
        }

        if (shouldAdd){
            housingInTransaction[row.Id].push({
                objectid: row.objectid,
                date: row.date,
                enddate: row.enddate,
                qcstate: row.QCState,
                room: row.room,
                cage: row.cage
            });
        }

        helper.setProperty('housingInTransaction', housingInTransaction);
    });
}

function onUpsert(helper, scriptErrors, row, oldRow){
    if (row.cage){
        row.cage = row.cage.toUpperCase();
    }
}