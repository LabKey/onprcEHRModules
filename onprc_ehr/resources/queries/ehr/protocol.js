/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);


    function onUpsert(helper, scriptErrors, row){
        row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase()
    }