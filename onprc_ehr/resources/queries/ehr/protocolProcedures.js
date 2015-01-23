/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

function onUpsert(helper, scriptErrors, row, oldRow){
    if (row && row.project){
        EHR.Server.Utils.addError(scriptErrors, 'project', 'You should probably leave this field blank.  Animal counts are usually associated with the IACUC itself.  The project field was left in place to support IRIS data, but should not be used unless there is a good reason to do so.', 'INFO');
    }
}
