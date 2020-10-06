/*
 * Copyright (c) 2012-2018 LabKey Corporation
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

    EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.INIT, function(event, helper, EHR){
        EHR.Server.Utils.isLiveBirth = function(birthCondition){
            EHR.Assert.assertNotEmpty('triggerHelper is null', triggerHelper);

            return !birthCondition ? true : triggerHelper.isBirthAlive(birthCondition);
        };

        helper.setScriptOptions({
            cacheAccount: false,
            //NOTE: this deliberately omits assignment, since it will be handled separately
            datasetsToClose: ['Cases', 'Housing', 'Treatment Orders', 'Notes', 'Problem List', 'Animal Record Flags', 'Diet', 'Animal Group Members']
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'arrival', function(event, helper, EHR) {
        helper.setScriptOptions({
            extraBirthFieldMappings: {
                arrival_date: 'date'
            }
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'treatment_order', function(event, helper){
        helper.setScriptOptions({
            announceAllModifiedParticipants: true
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'birth', function(event, helper){
        //NOTE: births are sometimes not entered until processing, meaning they could be significantly in the past
        helper.setScriptOptions({
            allowDatesInDistantPast: true
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'clinpathRuns', function(event, helper){
        helper.setScriptOptions({
            allowDeadIds: false,
            //this was changed to allow merge records to insert, even if we lack a demographics record
            allowAnyId: true
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'assignment', function(event, helper){
        helper.setScriptOptions({
            doStandardProtocolCountValidation: false
        });
    });

    //Added : 12-19-2017  R.Blasa
    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study','clinpathRuns', function(helper, scriptErrors, row, oldRow){
        helper.setScriptOptions({

            allowFutureDates: false  //Added: R.Blasa

        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.INIT, 'study', 'deaths', function(event, helper){
        helper.setScriptOptions({
            allowDatesInDistantPast: true
        });
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'tissue_samples', function(helper, scriptErrors, row, oldRow){
        if (!row.weight && !row.noWeight){
            EHR.Server.Utils.addError(scriptErrors, 'weight', 'A weight is required unless \'No Weight\' is checked', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'tasks', function(helper, scriptErrors, row, oldRow){
        row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'requests', function(helper, scriptErrors, row, oldRow){
        row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'encounter_summaries', function(helper, scriptErrors, row, oldRow){
        row.objectid = row.objectid || LABKEY.Utils.generateUUID().toUpperCase();
    });

    //note: encounter_participants objectid handled by the query's trigger script

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'clinical_observations', function(helper, scriptErrors, row, oldRow){
        if (row.category && LABKEY.ExtAdapter.isDefined(row.observation)){
            var msg = triggerHelper.validateObservation(row.category, row.observation);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'observation', msg, 'WARN');
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'encounters', function(helper, scriptErrors, row, oldRow)
    {
        if (row.chargetype == 'Research Staff' && !row.assistingstaff && row.procedureid && triggerHelper.requiresAssistingStaff(row.procedureid))
        {
            EHR.Server.Utils.addError(scriptErrors, 'chargetype', 'If choosing Research Staff, you must enter the assisting staff.', 'WARN');
        }

        if (row.chargetype != 'Research Staff' && row.assistingstaff)
        {
            EHR.Server.Utils.addError(scriptErrors, 'assistingstaff', 'This field will be ignored unless Research Staff is selected, and should be blank.', 'WARN');
        }

        if (row.type && row.caseno)
        {
            var msg = triggerHelper.validateCaseNo(row.caseno, row.type, row.objectid || null);
            if (msg)
            {
                EHR.Server.Utils.addError(scriptErrors, 'caseno', msg, 'WARN');
            }
        }
        //Modified: 10-17-2016 R.Blasa  flag procedure "ejaculation" for male gender
        if (row.Id && row.procedureid == 734 )
        {
            EHR.Server.Utils.findDemographics({
                participant: row.Id,
                helper: helper,
                scope: this,
                callback: function (data)
                {
                    if (data)
                    {
                        if (data['gender/origGender'] && data['gender/origGender'] != 'm')
                            EHR.Server.Utils.addError(scriptErrors, 'Id', 'This animal has to be a male', 'ERROR');
                    }
                }
            });
       }
    });
      //Added 1-12-2016  Blasa  Menses TMB Records
    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'study', 'clinical_observations', function(helper, scriptErrors, row, oldRow){

        if (row.Id && row.category == 'Menses' ){
            var msg = triggerHelper.sendMenseNotifications(row.Id);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'category', msg, 'ERROR');
            }
        }

    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'flags', function(helper, scriptErrors, row, oldRow){
        if (row.flag && row.Id && !row.enddate){
            var msg = triggerHelper.validateHousingConditionInsert(row.Id, row.flag, row.objectid || null);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'flag', msg, 'ERROR');
            }

        }
    });

    //Added 9-2-2015  Blasa
    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'study',  'flags', function(helper, scriptErrors, row, oldRow){

    if (row.Id ){
        var msg = triggerHelper.sendCullListNotifications(row.Id,row.date, row.flag);
        if (msg){
            EHR.Server.Utils.addError(scriptErrors, 'category', msg, 'ERROR');
        }
    }
});


    //Added 4-27-2016  R.Blasa
    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_INSERT, 'ehr',  'protocol', function(helper, scriptErrors, row, oldRow){

        if (row.protocol){
            console.log("protocol data collected  " + row.protocol)
            var msg = triggerHelper.sendProtocolNotifications(row.protocol);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'protocol', msg, 'ERROR');
            }
        }
    });

    //Added 8-27-2018  R.Blasa   Create  a new entry when housing condition, or housing type are modified
    // EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_INSERT, 'ehr_lookups',  'rooms', function(helper, scriptErrors, row, oldRow){
    //
    //     if (row.room == oldRow.room && row.cage == oldRow.cage && (oldRow.housingCondition != row.housingCondition || oldRow.housingType != row.houstingType) ){
    //
    //         //Create a log entry for billing as result of changes mades to  Room dataset
    //         var msg  =    triggerHelper.createHousingTyperecord(room, row.housingType,row.housingCondition);
    //         if (msg){
    //             EHR.Server.Utils.addError(scriptErrors, 'housingCondition', msg, 'INFO');
    //         }
    //         else {
    //             triggerHelper.createHousingTyperecord(row.Id, row.enddate, row.releaseCondition);
    //         }
    //
    //     }
    // });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'assignment', function(helper, scriptErrors, row, oldRow){
        //check number of allowed animals at assign/approve time.  use different behavior than core EHR
        if (!helper.isETL() && !helper.isQuickValidation() &&
            //this is designed to always perform the check on imports, but also updates where the Id was changed
                !(oldRow && oldRow.Id && oldRow.Id==row.Id) &&
                row.Id && row.project && row.date
        ){
            var assignmentsInTransaction = helper.getProperty('assignmentsInTransaction');
            assignmentsInTransaction = assignmentsInTransaction || [];

            //NOTE: include date to allow future assignment dates
            var msgs = triggerHelper.verifyProtocolCounts(row.Id, row.project, row.date, assignmentsInTransaction);
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
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'ehr', 'protocol', function(helper, scriptErrors, row){
        if (!row.protocol){
            row.protocol = triggerHelper.getNextProtocolId().toString();
        }
    });

    //Created: 1-17-2018 R.Blasa
    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'snomed_tags', function(helper, scriptErrors, row, oldRow){
        if (row.Id && !row.code){
            EHR.Server.Utils.addError(scriptErrors, 'code', 'A snomed code is required to continue', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'assignment', function(helper, scriptErrors, row, oldRow){
        // note: if this is automatically generated from death/departure, allow an incomplete record
        // alerts will flag these
        if (row.enddate && !row.releaseCondition && !helper.isGeneratedByServer()){
            EHR.Server.Utils.addError(scriptErrors, 'releaseCondition', 'Must provide the release condition when the release date is set', 'WARN');
        }

        if (row.enddate && !row.releaseType && !helper.isGeneratedByServer()){
            EHR.Server.Utils.addError(scriptErrors, 'releaseType', 'Must provide the release type when the release date is set', 'WARN');
        }

        //update condition on release
        if (!helper.isETL() && helper.getEvent() == 'update' && oldRow){
            if (EHR.Server.Security.getQCStateByLabel(row.QCStateLabel).PublicData && EHR.Server.Security.getQCStateByLabel(oldRow.QCStateLabel).PublicData){
                if (row.releaseCondition && row.enddate){
                    var msg = triggerHelper.checkForConditionDowngrade(row.Id, row.enddate, row.releaseCondition);
                    if (msg){
                        EHR.Server.Utils.addError(scriptErrors, 'releaseCondition', msg, 'INFO');
                    }
                    else {
                        triggerHelper.updateAnimalCondition(row.Id, row.enddate, row.releaseCondition);
                    }
                }
            }
        }

        // we want to record the date a record was marked endded, in addition to the actual end itself
        // NOTE: we only do this when both enddate and releaseType are entered
        if (!row.enddatefinalized && row.enddate && row.releaseCondition && EHR.Server.Security.getQCStateByLabel(row.QCStateLabel).PublicData){
            //note: if ended in the future, defer to that date
            row.enddatefinalized = new Date();
            if (row.enddate.getTime() > row.enddatefinalized.getTime()){
                row.enddatefinalized = row.enddate;
            }
        }

        //check for condition downgrade for assign condition
        if (!helper.isETL() && row.Id && row.assignCondition){
            var msg = triggerHelper.checkForConditionDowngrade(row.Id, row.date, row.assignCondition);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'assignCondition', msg, 'INFO');
            }
        }

        //check for condition downgrade for assign condition
        if (!helper.isETL() && row.Id && row.date && row.assignCondition){
            var msg = triggerHelper.checkForConditionDowngrade(row.Id, row.date, row.assignCondition);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'assignCondition', msg, 'INFO');
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'assignment', function(scriptErrors, helper, row, oldRow){
        if (!helper.isETL() && row.Id && row.assignCondition){
            triggerHelper.updateAnimalCondition(row.Id, row.date, row.assignCondition);
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'animal_group_members', function(helper, scriptErrors, row, oldRow){
        if (!helper.isETL() && row.Id && row.groupid && !row.enddate){
            var msg = triggerHelper.getOverlappingGroupAssignments(row.Id, row.objectid);
            if (msg){
                EHR.Server.Utils.addError(scriptErrors, 'groupId', msg, 'INFO');
            }
        }
        //Added: 12-29-2017  R.Blasa
        if (row.Id && !row.groupId){
            EHR.Server.Utils.addError(scriptErrors, 'groupId', 'A Group Id selection is required.', 'WARN');
        }
    });


     //Modified: 10-13-2016 R.Blasa added arrival date parameter
    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'study', 'birth', function(helper, errors, row, oldRow) {
        //Modified: 3-20-2017 R.Blasa  Fetal Prenatal updates
        if (row.id && oldRow)
        {
            if (row.id && oldRow.birth_condition && oldRow.birth_condition == 'Fetus - Prenatal' && row.birth_condition && row.birth_condition != 'Fetus - Prenatal')
            {
                //Modified: 10-27-2017
                triggerHelper.doBirthTriggers(row.Id, row.date, row.dam || null, row.Arrival_Date || null, row.birth_condition || null,row.species || null, !!row._becomingPublicData);

                //Added: 6-26-2017 R.Blasa
                //set active flag condition after changing status from Fetus Prenatal to Alive. (Needs to execute because it is no longer considered isBecomingPublic status)
                triggerHelper.doBirthConditionAfterPrenatal(row.Id, row.date, row.dam || null, row.Arrival_Date || null, row.birth_condition || null, !!row._becomingPublicData);

                //Created housing when room location is provided
                if (row.id && row.room)
                {
                    helper.getJavaHelper().createHousingRecord(row.Id, row.date, null, row.room, (row.cage || null), (row.initialCond || null));
                }
                //Added: 6-26-2017 R.Blasa
                //if a weight is provided, we insert into the weight table:
                if (row.weight && row.wdate)
                {
                    helper.getJavaHelper().insertWeight(row.Id, row.wdate, row.weight);
                }

            }
        }
        //Added: 6-27-2017  R,Blasa  Process only
        if (row.birth_condition != 'Fetus - Prenatal')
        {
            //NOTE: we want to perform the birth updates if this row is becoming public, or if we're updating to set the dam for the first time
            if (!helper.isValidateOnly() && (row._becomingPublicData || (oldRow && !oldRow.dam && EHR.Server.Security.getQCStateByLabel(row.QCStateLabel).PublicData && row.dam)))
            {
                triggerHelper.doBirthTriggers(row.Id, row.date, row.dam || null, row.Arrival_Date || null, row.birth_condition || null, row.species || null, !!row._becomingPublicData);
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'birth', function(helper, scriptErrors, row, oldRow) {
        //also allow changes here to update the demographics record
        //this should only occur if updating an already public record, not just for onBecomePublic, which is a one-time call
        if (!helper.isValidateOnly() && row.Id && !helper.isGeneratedByServer() && oldRow && EHR.Server.Security.getQCStateByLabel(oldRow.QCStateLabel).PublicData && EHR.Server.Security.getQCStateByLabel(row.QCStateLabel).PublicData){
            EHR.Server.Utils.findDemographics({
                participant: row.Id,
                helper: helper,
                scope: this,
                callback: function (data) {
                    data = data || {};

                    var obj = {};
                    var hasUpdates = false;

                    if (row.gender && row.gender != data.gender) {
                        obj.gender = row.gender;
                        hasUpdates = true;
                    }

                    if (row.species && row.species != data.species) {
                        obj.species = row.species;
                        hasUpdates = true;
                    }

                    if (row.dam && !data.species && !obj.species){
                        var damSpecies = triggerHelper.getSpeciesForDam(row.dam);
                        if (damSpecies){
                            obj.species = damSpecies;
                            hasUpdates = true;
                        }
                    }

                    if (row.geographic_origin && row.geographic_origin != data.geographic_origin){
                        obj.geographic_origin = row.geographic_origin;
                        hasUpdates = true;
                    }

                    if (row.dam && !obj.geographic_origin){
                        var damOrigin = triggerHelper.getGeographicOriginForDam(row.dam);
                        if (damOrigin){
                            obj.geographic_origin = damOrigin;
                            hasUpdates = true;
                        }
                    }

                    if (row.date && row.date.getTime() != (data.birth ? data.birth.getTime() : 0)) {
                        obj.birth = row.date;
                        hasUpdates = true;
                    }

                    //update death date in demographics if born dead
                    if (row.Id && row.date && !data.death && !triggerHelper.isBirthAlive(row.birth_condition || null)){
                        obj.death = row.date;
                        hasUpdates = true;

                        //if this is the first time a birth condition was entered, treat this the same as when a death is entered
                        if (oldRow && !oldRow.birth_condition){
                            helper.onDeathDeparture(row.Id, row.date);
                        }
                    }

                    if (hasUpdates){
                        obj.Id = row.Id;
                        var demographicsUpdates = [obj];
                        helper.getJavaHelper().updateDemographicsRecord(demographicsUpdates);
                    }
                }
            });
        }

        //Added: 1-17-2018  R.Blasa disallow male id
        if (row.dam )
        {
            EHR.Server.Utils.findDemographics({
                participant: row.dam ,
                helper: helper,
                scope: this,
                callback: function (data)
                {
                    if (data)
                    {
                        if (data['gender/origGender'] && data['gender/origGender'] != 'f')
                            EHR.Server.Utils.addError(scriptErrors, 'dam', 'The dam has to be female', 'ERROR');
                    }
                }
            });

        }
    });

    //Modified: 6-8-2018  R.Blasa
    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'study', 'deaths', function(helper, errors, row, oldRow){
        if (row.Id && row.date){
            //close assignment records.
            triggerHelper.closeActiveAssignmentRecords(row.Id, row.date, (row.cause || null));
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'drug', function(helper, scriptErrors, row, oldRow){
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
        //Added: 10-14-2016 R.Blasa
        if ((row.code == 'E-00070' || row.code == 'E-YY490'|| row.code == 'E-YYY45') && !row.remark){
            EHR.Server.Utils.addError(scriptErrors, 'remark', 'A remark is required when entering this medication', 'WARN');
        }

    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'treatment_order', function(helper, scriptErrors, row){
        if (row.date && ((new Date()).getTime() - row.date.getTime()) > 43200000){  //12 hours in past
            EHR.Server.Utils.addError(scriptErrors, 'date', 'You are ordering a treatment that starts in the past', 'INFO');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_INSERT, 'study', 'blood', function(helper, scriptErrors, row){
        if (!helper.isETL() && row.project && row.chargetype){
            if (row.chargetype == 'No Charge' && !helper.getJavaHelper().isDefaultProject(row.project))
                EHR.Server.Utils.addError(scriptErrors, 'chargetype', 'You have chosen \'No Charge\' with a project that does not support this.  You may need to choose \'Research\' instead (which is not billed)', 'INFO');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'housing', function(helper, scriptErrors, row, oldRow){
        if (row.cage){
            row.cage = row.cage.toUpperCase();
        }

        onprc_utils.doHousingCheck(EHR, helper, scriptErrors, triggerHelper, row, oldRow);

        //TODO: why are we duplicating this block?
        var msgs = onprc_utils.doUpdateDividers(EHR, row, helper, scriptErrors, triggerHelper, true);
        if (msgs){
            msgs = msgs.split("<>");
            for (var i=0;i<msgs.length;i++){
                EHR.Server.Utils.addError(scriptErrors, 'divider', msgs[i], 'INFO');
            }
        }

        //dont allow open ended housing for non-living animals
        if (!row.enddate && row.Id){
            EHR.Server.Utils.findDemographics({
                participant: row.Id,
                helper: helper,
                scope: this,
                callback: function(data){
                    if (data){
                        if (data.calculated_status == 'Unknown' || !data.calculated_status){
                            //NOTE: if the animal exists in the birth table, allow it
                            if (!data.hasBirthRecord) {
                                EHR.Server.Utils.addError(scriptErrors, 'enddate', 'There is no record of this animal, cannot enter an open ended housing record', 'WARN');
                            }
                        }
                        else if (data.calculated_status != 'Alive' && !data.hasBirthRecord){
                            EHR.Server.Utils.addError(scriptErrors, 'enddate', 'This animal is not listed as alive, cannot enter an open ended housing record', 'WARN');
                        }
                        //Added: 6-14-2017  R.Blasa
                        else if (data.calculated_status == 'Dead' || data.calculated_status == 'Shipped'){
                            EHR.Server.Utils.addError(scriptErrors, 'Id', 'This animal is deceased or shipped out, you are not allowed to make this changes to the housing record', 'WARN');
                        }
                    }
                }
            });
        }

        if (row.birth_date_type == 'Undetermined'){
            EHR.Server.Utils.addError(scriptErrors, 'birth_date_type', 'You can save records with Undetermined; however, you will need to change this before finalizing the form', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'housing', function(scriptErrors, helper, row, oldRow){
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

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'arrival', function(helper, scriptErrors, row, oldRow){
        //Don't process normally if Pending -- Modified: 4-25-2017 R.Blasa
        var acquiValue = triggerHelper.retrieveAcquisitionType(row.acquisitionType);
        if (row.id && acquiValue != 'Pending Arrival')
        {
            onprc_utils.doHousingCheck(EHR, helper, scriptErrors, triggerHelper, row, oldRow, 'initialRoom', 'initialCage', false);
        }
    });


    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'arrival', function(scriptErrors, helper, row, oldRow) {
        //Don't process normally if Pending -- Modified: 4-5-2017 R.Blasa
        var acquiValue = triggerHelper.retrieveAcquisitionType(row.acquisitionType);
        if (row.id && acquiValue != 'Pending Arrival')
        {
            if (row.Id && row.date)
            {
                console.log('Qurantine flag')
                triggerHelper.ensureQuarantineFlag(row.Id, row.date);
            }
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'birth', function(helper, scriptErrors, row, oldRow){
        onprc_utils.doHousingCheck(EHR, helper, scriptErrors, triggerHelper, row, oldRow, null, null, false);
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'study', 'arrival', function(helper, errors, row, oldRow) {
            //Don't process normally if Pending -- Created: 4-25-2017 R.Blasa
        if (row.id && oldRow)
        {
            var acquiValueOld = triggerHelper.retrieveAcquisitionType(oldRow.acquisitionType);
            var acquiValue = triggerHelper.retrieveAcquisitionType(row.acquisitionType);
            if (row.id && acquiValueOld == 'Pending Arrival' && acquiValue != 'Pending Arrival' && EHR.Server.Security.getQCStateByLabel(row.QCStateLabel).PublicData)
            {
                //Add Housing record if room provided
                if (row.initialRoom)
                {
                    helper.getJavaHelper().createHousingRecord(row.Id, row.date, null, row.initialRoom, (row.initialCage || null), (row.initialCond || null));
                }

                //Add Birth record
                triggerHelper.onAnimalArrival_AddBirth(row.id, row);

                triggerHelper.ensureQuarantineFlag(row.Id, row.date);

            }

        }

        if(row.id)
        {
            //Update demographics records
            EHR.Server.Utils.findDemographics({
                participant: row.id,
                helper: helper,
                scope: this,
                callback: function (data)
                {
                    data = data || {};

                    var obj = {};
                    var hasUpdates = false;

                    if (row.gender && row.gender != data.gender )
                    {
                        obj.gender = row.gender;
                        hasUpdates = true;
                    }

                    if (row.species && row.species != data.species )
                    {
                        obj.species = row.species;
                        hasUpdates = true;
                    }

                    if (row.geographic_origin && row.geographic_origin != data.geographic_origin )
                    {
                        obj.geographic_origin = row.geographic_origin;
                        hasUpdates = true;
                    }

                    if (row.birth && row.birth.getTime() != (data.birth ? data.birth.getTime() : 0))
                    {
                        obj.birth = row.birth;
                        hasUpdates = true;
                    }


                    if (hasUpdates)
                    {
                        obj.Id = row.id;
                        var demographicsUpdates = [obj];
                        helper.getJavaHelper().updateDemographicsRecord(demographicsUpdates);
                    }

                }
            });
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'treatment_order', function(scriptErrors, helper, row, oldRow){
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

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'drug', function(scriptErrors, helper, row, oldRow){
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

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'study', 'treatment_order', function(helper, scriptErrors, row, oldRow){
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
        //Added: 10-14-2016 R.Blasa
        if ((row.code == 'E-00070' || row.code == 'E-YY490'|| row.code == 'E-YYY45') && !row.remark){
            EHR.Server.Utils.addError(scriptErrors, 'remark', 'A remark is required when entering this medication', 'WARN');
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'study', 'treatment_order', function(helper, errors, row, oldRow){
        if (row.frequency && row.objectid){
            triggerHelper.cleanTreatmentFrequencyTimes(row.frequency, row.objectid);
        }
    });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPDATE, 'study', 'treatment_order', function(helper, scriptErrors, row, oldRow){
        if (helper.isETL() || helper.isValidateOnly()){
            return;
        }
        //Modified: 7-12-2017  R.blasa
        if (row && oldRow ){
            EHR.Assert.assertNotEmpty('triggerHelper is null', triggerHelper);

            var date = triggerHelper.onTreatmentOrderChange(row, oldRow);
            if (date){
                row.date = date;
            }
        }
    });

    // //Added: 9-7-2018  R.Blasa
    // EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.AFTER_UPSERT, 'study', 'encounters', function(helper, errors, row, oldRow) {
    //     //Create an immediate alert notification when this is created
    //     // if (row.id &&  row.procedureid == 2440) {
    //         if (row.id &&  row.procedureid == 2094) {
    //         //Update demographics records
    //         console.log("ASB Procedure Request Complete NOP  " + row.procedureid);
    //         var msg = triggerHelper.sendASBProcedureNOPRequestNotification(row.id);
    //             if (msg){
    //                 EHR.Server.Utils.addError(scriptErrors, 'procedureid', msg, 'ERROR');
    //             }
    //          }
    //     });

    EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.ON_BECOME_PUBLIC, 'study', 'clinremarks', function(scriptErrors, helper, row, oldRow){
        if (helper.isETL() || helper.isValidateOnly()){
            return;
        }

        if (row && row.category == 'Replacement SOAP' && row.parentid){
            EHR.Assert.assertNotEmpty('triggerHelper is null', triggerHelper);

            triggerHelper.replaceSoap(row.parentid);
        }
    });


    EHR.Server.TriggerManager.registerHandler(EHR.Server.TriggerManager.Events.INIT, function (event, helper) {
        // Override the default EHR validation for project creation
        EHR.Server.TriggerManager.unregisterAllHandlersForQueryNameAndEvent('ehr', 'project', EHR.Server.TriggerManager.Events.BEFORE_UPSERT);

        EHR.Server.TriggerManager.registerHandlerForQuery(EHR.Server.TriggerManager.Events.BEFORE_UPSERT, 'ehr', 'project', function (helper, scriptErrors, row, oldRow) {
            var constraintHelper = org.labkey.ldk.query.UniqueConstraintHelper.create(LABKEY.Security.currentContainer.id, LABKEY.Security.currentUser.id, 'ehr', 'project_active', 'name');
            console.log("ONPRC insert handler");
            //enforce name unique
            if (row.name) {
                var isValid = constraintHelper.validateKey(row.name, oldRow ? (oldRow.name || null) : null);
                if (!isValid) {
                    EHR.Server.Utils.addError(scriptErrors, 'name', 'There is already an old project with the name in ehr: ' + row.name, 'ERROR');
                }
            }
        });
    });
};