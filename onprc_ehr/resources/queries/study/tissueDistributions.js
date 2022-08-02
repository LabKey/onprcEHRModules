/*
 * Copyright (c) 2013-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

require("ehr/triggers").initScript(this);

EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'tisssueDistributions', function (helper, scriptErrors, row, oldRow) {
    helper.decodeExtraContextProperty('TissueCodeInTransaction');
    var TissueCodeInTransaction = helper.getProperty('TissueCodeInTransaction');

    if (TissueCodeInTransaction && !TissueCodeInTransaction['TissueCodesEntered']) {
        EHR.Server.Utils.addError(scriptErrors, 'Id', 'billing charges grid requires at least one row', 'WARN');
    }
});

