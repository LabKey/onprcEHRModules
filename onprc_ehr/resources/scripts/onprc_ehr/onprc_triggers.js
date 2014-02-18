/*
 * Copyright (c) 2012-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var console = require("console");
var LABKEY = require("labkey");
var ETL = require("onprc_ehr/etl").EHR.ETL;
var triggerHelper = new org.labkey.onprc_ehr.query.ONPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

exports.init = function(EHR){
    EHR.ETL = ETL;

    EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.INIT, function(event, helper){
        helper.setScriptOptions({
            cacheAccount: false
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Drug Administration', function(helper, scriptErrors, row, oldRow){
        if (row.outcome && row.outcome != 'Normal' && !row.remark){
            EHR.Server.Utils.addError(scriptErrors, 'remark', 'A remark is required if a non-normal outcome is reported', 'WARN');
        }

        if (!row.code){
            EHR.Server.Utils.addError(scriptErrors, 'code', 'Must enter a treatment', 'WARN');
        }
        else if ((row.code == 'E-70590' || row.code == 'E-YY928') && (row.amount || row.volume) && (!row.amount || !row.amount_units || row.amount_units.toLowerCase() != 'mg')){
            EHR.Server.Utils.addError(scriptErrors, 'amount_units', 'When entering ketamine or telazol, amount must be in mg', 'WARN');
        }

        if (!row.amount && !row.volume){
            EHR.Server.Utils.addError(scriptErrors, 'amount', 'Must enter an amount or volume', 'WARN');
            EHR.Server.Utils.addError(scriptErrors, 'volume', 'Must enter an amount or volume', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'Treatment Orders', function(helper, scriptErrors, row){
        if (row.date && ((new Date()).getTime() - row.date.getTime()) > 3600000){  //one hour in past
            EHR.Server.Utils.addError(scriptErrors, 'date', 'Note: you are ordering a treatment that starts in the past', 'INFO');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'Blood Draws', function(helper, scriptErrors, row){
        if (!helper.isETL() && row.project && row.chargetype){
            if (row.chargetype == 'No Charge' && !helper.getJavaHelper().isDefaultProject(row.project))
                EHR.Server.Utils.addError(scriptErrors, 'chargetype', 'You have chosen \'No Charge\' with a project that does not support this.  You may need to choose \'Research\' instead (which is not billed)', 'INFO');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Treatment Orders', function(scriptErrors, helper, row, oldRow){
        var fieldPairs = [
            ['dosage_units', 'dosage'],
            ['conc_units', 'concentration'],
            ['vol_units', 'volume'],
            ['amount_units', 'amount']
        ];

        //if we have a value entered for units, but no value in the corresponding numeric field, clear units
        for (var i=0;i<fieldPairs.length;i++){
            var pair = fieldPairs[i];
            if (row[pair[0]] && LABKEY.ExtAdapter.isEmpty(row[pair[1]])){
                row[pair[0]] = null;
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Drug Administration', function(scriptErrors, helper, row, oldRow){
        var fieldPairs = [
            ['dosage_units', 'dosage'],
            ['conc_units', 'concentration'],
            ['vol_units', 'volume'],
            ['amount_units', 'amount']
        ];

        //if we have a value entered for units, but no value in the corresponding numeric field, clear units
        for (var i=0;i<fieldPairs.length;i++){
            var pair = fieldPairs[i];
            if (row[pair[0]] && LABKEY.ExtAdapter.isEmpty(row[pair[1]])){
                row[pair[0]] = null;
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Treatment Orders', function(helper, scriptErrors, row, oldRow){
        if (!row.code){
            EHR.Server.Utils.addError(scriptErrors, 'code', 'Must enter a treatment', 'WARN');
        }
        else if ((row.code == 'E-70590' || row.code == 'E-YY928') && (row.amount || row.volume) && (!row.amount || !row.amount_units || row.amount_units.toLowerCase() != 'mg')){
            EHR.Server.Utils.addError(scriptErrors, 'amount_units', 'When entering ketamine or telazol, amount must be in mg', 'WARN');
        }

        if (!row.amount && !row.volume){
            EHR.Server.Utils.addError(scriptErrors, 'amount', 'Must enter an amount or volume', 'WARN');
            EHR.Server.Utils.addError(scriptErrors, 'volume', 'Must enter an amount or volume', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPDATE, 'study', 'Treatment Orders', function(helper, scriptErrors, row, oldRow){
        if (helper.isETL() || helper.isValidateOnly()){
            return;
        }

        if (row && oldRow){
            EHR.Assert.assertNotEmpty('triggerHelper is null', triggerHelper);

            var date = triggerHelper.onTreatmentOrderChange(row, oldRow);
            if (date){
                row.date = date;
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Clinical Remarks', function(scriptErrors, helper, row, oldRow){
        if (helper.isETL() || helper.isValidateOnly()){
            return;
        }

        if (row && row.category == 'Replacement SOAP' && row.parentid){
            EHR.Assert.assertNotEmpty('triggerHelper is null', triggerHelper);

            triggerHelper.replaceSoap(row.parentid);
        }
    });
};