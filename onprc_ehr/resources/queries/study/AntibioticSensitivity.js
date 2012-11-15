/*
 * Copyright (c) 2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

var {EHR, LABKEY, Ext, console, init, beforeInsert, afterInsert, beforeUpdate, afterUpdate, beforeDelete, afterDelete, complete} = require("ehr/triggers");

function setDescription(row, errors){
    //we need to set description for every field
    var description = new Array();

    if(row.tissue || row.tissueMeaning)
        description.push('Tissue: '+EHR.Server.Validation.snomedToString(row.tissue,  row.tissueMeaning));
    if(row.microbe || row.microbeMeaning)
        description.push('Code: '+EHR.Server.Validation.snomedToString(row.microbe,  row.microbeMeaning));
    if(row.antibiotic || row.antibioticMeaning)
        description.push('Code: '+EHR.Server.Validation.snomedToString(row.antibiotic,  row.antibioticMeaning));
    if(!LABKEY.ExtAdapter.isEmpty(row.resistant))
        description.push('Resistant to antibiotics?: '+EHR.Server.Validation.nullToString(row.resistant);

    return description;
}
