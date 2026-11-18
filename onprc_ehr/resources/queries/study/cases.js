/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);
var triggerHelper = new org.labkey.onprc_ehr.query.ONPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'Cases', function(helper, errors, row, oldRow){
    // Fill in case number on case insert
    if (!helper.isValidateOnly() && !helper.isETL() && !row.caseNo){
        row.caseNo = triggerHelper.getNextCaseDisplayId();
    }
});