/*
 * Copyright (c) 2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var console = require("console");
var LABKEY = require("labkey");
var Ext = require("Ext4").Ext;

var ETL = require("onprc_ehr/etl").EHR.ETL;

exports.init = function(EHR){
    EHR.ETL = ETL;

    EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, function(errors, row, oldRow){
        console.log('called!!!!');
    });
}