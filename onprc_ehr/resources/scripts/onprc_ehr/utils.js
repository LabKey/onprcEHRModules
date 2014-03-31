/*
 * Copyright (c) 2011-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

var console = require("console");
var LABKEY = require("labkey");

var ONPRC_EHR = {};
exports.ONPRC_EHR = ONPRC_EHR;

ONPRC_EHR.Utils = new function(){
    return {
        doHousingCheck: function(EHR, helper, scriptErrors, triggerHelper, row, roomField, cageField){
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
                    var cageMsg = triggerHelper.validateCage(row[roomField], row[cageField]);
                    if (cageMsg){
                        EHR.Server.Utils.addError(scriptErrors, cageField, cageMsg, 'WARN');
                    }

                    var map = helper.getProperty('housingInTransaction');
                    var housingRecords = [];
                    if (map){
                        for (var key in map){
                            housingRecords = housingRecords.concat(map[key]);
                        }
                    }

                    var previousCagemates = [];
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
                    }

                    var cagemates = triggerHelper.getAnimalsAfterMove(row[roomField], row[cageField], housingRecords);
                    cagemates = cagemates ? cagemates.split(';') : [];
                    cagemates = cagemates.sort();

                    //alert if pairs are broken
                    if (previousCagemates.length){
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
                            EHR.Server.Utils.findDemographics({
                                participant: animal,
                                helper: helper,
                                scope: this,
                                callback: function(data){
                                    if (data && data.mostRecentWeight){
                                        weights.push(data.mostRecentWeight);
                                    }
                                }
                            });
                        }

                        var cageSizeMsgs = triggerHelper.verifyCageSize(row[roomField], row[cageField], weights);
                        if (cageSizeMsgs && cageSizeMsgs.length){
                            for (var i=0;i<cageSizeMsgs.length;i++){
                                EHR.Server.Utils.addError(scriptErrors, cageField, cageSizeMsgs[i], 'INFO');
                                EHR.Server.Utils.addError(scriptErrors, 'Id', cageSizeMsgs[i], 'INFO');
                            }
                        }
                    }
                }

                //TODO: alert if there are pending requests for this Id
            }
        }
    }
}

