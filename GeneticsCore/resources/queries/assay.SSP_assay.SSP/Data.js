var LABKEY = require("labkey");

var triggerHelper = new org.labkey.GeneticsCore.GeneticsCoreTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id, this.schemaName, 'Data');

function afterDelete(row) {
    triggerHelper.addAuditForResult(row.subjectId, row);
}