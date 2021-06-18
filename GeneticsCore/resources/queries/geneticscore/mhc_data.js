var LABKEY = require("labkey");

function beforeInsert(row) {
    row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
}