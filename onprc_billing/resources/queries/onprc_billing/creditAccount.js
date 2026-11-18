/*
 * Copyright (c) 2014-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var ldkUtils = require("ldk/Utils").LDK.Server.Utils;

function beforeInsert(row, errors){
    beforeUpsert(row, errors);
}

function beforeUpdate(row, errors){
    beforeUpsert(row, errors);
}

function beforeUpsert(row, errors){
    if (row.startDate){
        row.startDate = ldkUtils.removeTimeFromDate(row.startDate);
    }

    if (row.endDate){
        row.endDate = ldkUtils.removeTimeFromDate(row.endDate);
    }
}