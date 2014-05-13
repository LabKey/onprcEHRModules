/*
 * Copyright (c) 2012-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
var console = require("console");
var LABKEY = require("labkey");
var ETL = require("onprc_ehr/etl").EHR.ETL;
var onprc_utils = require("onprc_ehr/utils").ONPRC_EHR.Utils;
var triggerHelper = new org.labkey.onprc_ehr.query.ONPRC_EHRTriggerHelper(LABKEY.Security.currentUser.id, LABKEY.Security.currentContainer.id);

exports.init = function(EHR){
    EHR.ETL = ETL;

    EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.INIT, function(event, helper){
        helper.setScriptOptions({
            cacheAccount: false
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'Treatment Orders', function(event, helper){
        helper.setScriptOptions({
            announceAllModifiedParticipants: true
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'Clinpath Runs', function(event, helper){
        helper.setScriptOptions({
            allowDeadIds: false,
            allowAnyId: false
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'Assignment', function(event, helper){
        helper.setScriptOptions({
            doStandardProtocolCountValidation: false
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Tissue Samples', function(helper, scriptErrors, row, oldRow){
        if (!row.weight && !row.noWeight){
            EHR.Server.Utils.addError(scriptErrors, 'weight', 'A weight is required unless \'No Weight\' is checked', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'Animal Record Flags', function(helper, scriptErrors, row, oldRow){
        if (row.flag && row.Id && !row.enddate){
            var msg = triggerHelper.validateHousingConditionInsert(row.Id, row.flag, row.objectid);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'flag', msg, 'ERROR');
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'Assignment', function(helper, scriptErrors, row, oldRow){
        //check number of allowed animals at assign/approve time.  use different behavior than core EHR
        if (!helper.isETL() && !helper.isQuickValidation() &&
            //this is designed to always perform the check on imports, but also updates where the Id was changed
                !(oldRow && oldRow.Id && oldRow.Id==row.Id) &&
                row.Id && row.project && row.date
        ){
            var assignmentsInTransaction = helper.getProperty('assignmentsInTransaction');
            assignmentsInTransaction = assignmentsInTransaction || [];

            var msgs = triggerHelper.verifyProtocolCounts(row.Id, row.project, assignmentsInTransaction);
            if (msgs){
                msgs = msgs.split("<>");
                for (var i=0;i<msgs.length;i++){
                    EHR.Server.Utils.addError(scriptErrors, 'project', msgs[i], 'INFO');
                }
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'ehr', 'project', function(helper, scriptErrors, row){
        if (!row.project){
            row.project = triggerHelper.getNextProjectId();
            console.log('setting projectId: ' + row.project);
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'ehr', 'protocol', function(helper, scriptErrors, row){
        if (!row.protocol){
            row.protocol = triggerHelper.getNextProtocolId();
            console.log('setting protocol: ' + row.protocol);
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Assignment', function(helper, scriptErrors, row, oldRow){
        if (row.enddate && !row.releaseCondition){
            EHR.Server.Utils.addError(scriptErrors, 'releaseCondition', 'Must provide the release condition when the release date is set', 'WARN');
        }

        if (row.enddate && !row.releaseType){
            EHR.Server.Utils.addError(scriptErrors, 'releaseType', 'Must provide the release type when the release date is set', 'WARN');
        }

        //update condition on release
        if (!helper.isETL() && helper.getEvent() == 'update' && oldRow){
            if (EHR.Server.Security.getQCStateByLabel(row.QCStateLabel).PublicData && EHR.Server.Security.getQCStateByLabel(oldRow.QCStateLabel).PublicData){
                if (row.releaseCondition && row.enddate){
                    triggerHelper.updateAnimalCondition(row.Id, row.enddate, row.releaseCondition);
                }
            }
        }

        // we want to record the date a record was marked endded, in addition to the actual end itself
        // NOTE: we only do this when both enddate and releaseType are entered
        if (!row.enddatefinalized && row.enddate && row.releaseCondition && EHR.Server.Security.getQCStateByLabel(row.QCStateLabel).PublicData){
            console.log('setting enddatefinalized');
            row.enddatefinalized = new Date();
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Assignment', function(scriptErrors, helper, row, oldRow){
        if (!helper.isETL() && row.Id && row.assignCondition){
            triggerHelper.updateAnimalCondition(row.Id, row.date, row.assignCondition);
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'animal_group_members', function(helper, scriptErrors, row, oldRow){
        if (!helper.isETL() && row.Id && row.groupid && !row.enddate){
            var msg = triggerHelper.getOverlappingGroupAssignments(row.Id, row.objectid);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'groupId', msg, 'INFO');
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Birth', function(scriptErrors, helper, row, oldRow){
        triggerHelper.doBirthTriggers(row.Id, row.date, row.dam, row.cond);
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
        if (row.date && ((new Date()).getTime() - row.date.getTime()) > 43200000){  //12 hours in past
            EHR.Server.Utils.addError(scriptErrors, 'date', 'You are ordering a treatment that starts in the past', 'INFO');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'Blood Draws', function(helper, scriptErrors, row){
        if (!helper.isETL() && row.project && row.chargetype){
            if (row.chargetype == 'No Charge' && !helper.getJavaHelper().isDefaultProject(row.project))
                EHR.Server.Utils.addError(scriptErrors, 'chargetype', 'You have chosen \'No Charge\' with a project that does not support this.  You may need to choose \'Research\' instead (which is not billed)', 'INFO');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Housing', function(helper, scriptErrors, row, oldRow){
        onprc_utils.doHousingCheck(EHR, helper, scriptErrors, triggerHelper, row, oldRow);

        //also attempt to update dividers
        var msgs = onprc_utils.doUpdateDividers(EHR, row, helper, scriptErrors, triggerHelper, true);
        if (msgs){
            msgs = msgs.split("<>");
            for (var i=0;i<msgs.length;i++){
                EHR.Server.Utils.addError(scriptErrors, 'divider', msgs[i], 'INFO');
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'Housing', function(scriptErrors, helper, row, oldRow){
        if (!helper.isETL() && row){
            //mark associated requests complete
            if (row.parentid){
                triggerHelper.markHousingTransferRequestsComplete(row.parentid);
            }

            //also attempt to update dividers
            var msgs = onprc_utils.doUpdateDividers(EHR, row, helper, scriptErrors, triggerHelper, helper.isValidateOnly());
            if (msgs){
                msgs = msgs.split("<>");
                for (var i=0;i<msgs.length;i++){
                    EHR.Server.Utils.addError(scriptErrors, 'divider', msgs[i], 'INFO');
                }
            }

            if (row.room){
                row.housingCondition = row.housingCondition || triggerHelper.getHousingCondition(row.room);
                row.housingType = row.housingType || triggerHelper.getHousingType(row.room);
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'onprc_ehr', 'housing_transfer_requests', function(helper, scriptErrors, row, oldRow){
        onprc_utils.doHousingCheck(EHR, helper, scriptErrors, triggerHelper, row, oldRow);
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Arrival', function(helper, scriptErrors, row, oldRow){
        onprc_utils.doHousingCheck(EHR, helper, scriptErrors, triggerHelper, row, oldRow, 'initialRoom', 'initialCage');
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'Birth', function(helper, scriptErrors, row, oldRow){
        onprc_utils.doHousingCheck(EHR, helper, scriptErrors, triggerHelper, row, oldRow);
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

        if (row.frequency){
            if (!triggerHelper.isTreatmentFrequencyActive(row.frequency)){
                EHR.Server.Utils.addError(scriptErrors, 'frequency', 'This frequency has been disabled.  Please select a different option', 'INFO');
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'study', 'Treatment Orders', function(helper, errors, row, oldRow){
        if (row.frequency && row.objectid){
            triggerHelper.cleanTreatmentFrequencyTimes(row.frequency, row.objectid);
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPDATE, 'study', 'Treatment Orders', function(helper, scriptErrors, row, oldRow){
        if (helper.isETL() || helper.isValidateOnly()){
            return;
        }

        if (row && oldRow && row.category != 'Research'){
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