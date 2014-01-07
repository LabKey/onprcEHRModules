/*
 * Copyright (c) 2012-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var console = require("console");
var LABKEY = require("labkey");
var ETL = require("onprc_ehr/etl").EHR.ETL;

exports.init = function(EHR){
    EHR.ETL = ETL;

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Drug Administration', function(helper, scriptErrors, row, oldRow){
        if (row.outcome && row.outcome != 'Normal' && !row.remark){
            EHR.Server.Utils.addError(scriptErrors, 'remark', 'A remark is required if a non-normal outcome is reported', 'WARN');
        }

        if (!row.code){
            EHR.Server.Utils.addError(scriptErrors, 'code', 'Must enter a treatment', 'WARN');
        }
        else if ((row.code == 'E-70590' || row.code == 'E-YY928') && row.amount && row.amount_units && row.amount_units.toLowerCase() != 'mg'){
            EHR.Server.Utils.addError(scriptErrors, 'amount_units', 'When entering ketamine or telazol, amount must be in mg', 'WARN');
        }

        if (!row.amount && !row.volume){
            EHR.Server.Utils.addError(scriptErrors, 'amount', 'Must enter an amount or volume', 'WARN');
            EHR.Server.Utils.addError(scriptErrors, 'volume', 'Must enter an amount or volume', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Treatment Orders', function(helper, scriptErrors, row, oldRow){
        if (!row.code){
            EHR.Server.Utils.addError(scriptErrors, 'code', 'Must enter a treatment', 'WARN');
        }
        else if ((row.code == 'E-70590' || row.code == 'E-YY928') && row.amount && row.amount_units && row.amount_units.toLowerCase() != 'mg'){
            EHR.Server.Utils.addError(scriptErrors, 'amount_units', 'When entering ketamine or telazol, amount must be in mg', 'WARN');
        }

        if (!row.amount && !row.volume){
            EHR.Server.Utils.addError(scriptErrors, 'amount', 'Must enter an amount or volume', 'WARN');
            EHR.Server.Utils.addError(scriptErrors, 'volume', 'Must enter an amount or volume', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'ehr', 'project', function(helper, scriptErrors, row, oldRow){
        if (helper.isETL()){
            return;
        }

        if (row && oldRow && row.project == oldRow.project && row.account != oldRow.account){
            var triggerHelper = new org.labkey.onprc_ehr.query.ONPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);
            triggerHelper.processProjectAccountChange(row.project, row.account, oldRow.account);
        }
    });

};