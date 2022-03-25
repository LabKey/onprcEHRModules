/*created by jonesa 2022-03-25*/


require("ehr/triggers").initScript(this);

function onUpsert(helper, scriptErrors, row){
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase()
}
