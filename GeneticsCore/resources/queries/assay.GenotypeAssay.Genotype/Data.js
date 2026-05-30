/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var LABKEY = require("labkey");

var triggerHelper = new org.labkey.GeneticsCore.GeneticsCoreTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id, this.schemaName, 'Data');

function afterDelete(row) {
    triggerHelper.addAuditForResult(row.subjectId, row);
}