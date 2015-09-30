/*
 * Copyright (c) 2014-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

var console = require("console");
var LABKEY = require("labkey");

var ONPRC_EHR = {};
exports.ONPRC_EHR = ONPRC_EHR;

ONPRC_EHR.Utils = new function(){
    return {
        doHousingCheck: function(EHR, helper, scriptErrors, triggerHelper, row, oldRow, roomField, cageField, alertOnPairSplit){
            roomField = roomField || 'room';
            cageField = cageField || 'cage';

            //only validate these for active housing records
            if (!helper.isETL() && !row.enddate){
                if (row[roomField]){
                    var supportsCages = triggerHelper.isCageRequired(row[roomField]);
                    if (supportsCages && !row[cageField]){
                        EHR.Server.Utils.addError(scriptErrors, cageField, 'This location requires a cage to be entered', 'WARN');
                    }
                }

                if (row[roomField] && row[cageField]){
                    var cageMsg = triggerHelper.validateCage(row[roomField], row[cageField], !!row.divider);
                    if (cageMsg){
                        EHR.Server.Utils.addError(scriptErrors, cageField, cageMsg, 'INFO');
                    }

                    var map = helper.getProperty('housingInTransaction');
                    var housingRecords = [];
                    if (map){
                        for (var key in map){
                            housingRecords = housingRecords.concat(map[key]);
                        }
                    }

                    var cagemates = triggerHelper.getAnimalsAfterMove(row[roomField], row[cageField], housingRecords);
                    cagemates = cagemates ? cagemates.split(';') : [];
                    cagemates = cagemates.sort();

                    var previousCagemates = [];
                    var oldLocationsSupportsCages = true;
                    var ar = helper.getJavaHelper().getDemographicRecord(row.Id);
                    if (ar != null){
                        var cm = ar.getProps().cagemates;
                        if (cm && cm.length){
                            for (var i=0;i<cm.length;i++){
                                previousCagemates = cm[i].animals;
                                previousCagemates = previousCagemates ? previousCagemates.split(', ') : [];
                                previousCagemates = previousCagemates.sort();
                            }
                        }

                        if (ar.getCurrentRoom()){
                            oldLocationsSupportsCages = triggerHelper.isCageRequired(ar.getCurrentRoom());
                        }
                    }

                    //alert if pairs are broken
                    if (alertOnPairSplit !== false && oldLocationsSupportsCages && previousCagemates.length){
                        var separated = [];
                        for (var i=0;i<previousCagemates.length;i++){
                            if (cagemates.indexOf(previousCagemates[i]) == -1){
                                separated.push(previousCagemates[i]);
                            }
                        }

                        if (separated.length){
                            EHR.Server.Utils.addError(scriptErrors, 'Id', 'This move will split a pair', 'INFO');
                        }
                    }

                    if (cagemates && cagemates.length){
                        var weights = [];
                        for (var i=0;i<cagemates.length;i++){
                            var animal = cagemates[i];
                            if (animal) {
                                EHR.Server.Utils.findDemographics({
                                    participant: animal,
                                    helper: helper,
                                    scope: this,
                                    callback: function (data) {
                                        if (data && data.mostRecentWeight) {
                                            weights.push(data.mostRecentWeight);
                                        }
                                    }
                                });
                            }
                        }

                        var cageSizeMsgs = triggerHelper.verifyCageSize(row[roomField], row[cageField], weights);
                        if (cageSizeMsgs && cageSizeMsgs.length){
                            for (var i=0;i<cageSizeMsgs.length;i++){
                                EHR.Server.Utils.addError(scriptErrors, cageField, cageSizeMsgs[i], 'INFO');
                                EHR.Server.Utils.addError(scriptErrors, 'Id', cageSizeMsgs[i], 'INFO');
                            }

                            // note: if entering an animal in a small cage, we allow this enter due to the possibility of false positives blocking valid transfers
                            // however, we require the user to enter a remark explaining this
                            if (!row.remark){
                                EHR.Server.Utils.addError(scriptErrors, cageField, 'You are required to enter a remark', 'INFO');
                                EHR.Server.Utils.addError(scriptErrors, 'Id', 'You are required to enter a remark', 'INFO');
                                EHR.Server.Utils.addError(scriptErrors, 'remark', 'A remark is required because of the case size errors.', 'WARN');
                            }
                        }
                    }
                }

                //TODO: alert if there are pending requests for this Id
            }
        },

        doUpdateDividers: function(EHR, row, helper, scriptErrors, triggerHelper, isValidateOnly){
            if (row.divider && row.room && row.cage){
                var map = helper.getProperty('housingInTransaction');
                var rows = [];
                for (var id in map){
                    rows = rows.concat(map[id]);
                }

                var msgs = triggerHelper.updateDividers(row.Id, row.room, row.cage, row.divider, isValidateOnly, rows);
                if (msgs){
                    msgs = msgs.split("<>");
                    for (var i=0;i<msgs.length;i++){
                        EHR.Server.Utils.addError(scriptErrors, 'divider', msgs[i], 'INFO');
                    }
                }
            }
        }
    }
}

