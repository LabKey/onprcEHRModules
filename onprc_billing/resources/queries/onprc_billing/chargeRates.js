var ldkUtils = require("ldk/Utils").LDK.Server.Utils;
var console = require("console");

function beforeInsert(row, errors){
    console.log("Inserting, original subsidy value: " + row.subsidy);
    if (!row.subsidy)
    {
        row.subsidy = 0;
    }
    beforeUpsert(row, errors);
}

function beforeUpdate(row, errors){
    beforeUpsert(row, errors);
}

function beforeUpsert(row, errors){
    if (row.startDate){
        // normalize to date-only (00:00)
        row.startDate = ldkUtils.removeTimeFromDate(row.startDate);
    }

    if (row.endDate){
        // normalize to date-only first
        var cleanDate = ldkUtils.removeTimeFromDate(row.endDate);

        // create a new date object set to 23:59
        var endOfDay = new Date(cleanDate);
        endOfDay.setHours(23, 59, 0, 0);

        row.endDate = endOfDay;
    }
}