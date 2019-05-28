/*
 * Copyright (c) 2012-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

var console = require("console");
var LABKEY = require("labkey");

var EHR = {};
exports.EHR = EHR;

EHR.Server = {};

EHR.Server.Validation = require("ehr/validation").EHR.Server.Validation;

EHR.Server.Utils = require("ehr/utils").EHR.Server.Utils;

/**
 * @deprecated
 * This was originally used to transform data being imported from the legacy mySQL system.
 * It should be written out of the validation script at some point.
 */
EHR.ETL = {
    fixRow: function(helper, errors, row){
        //inserts a date if missing
        EHR.ETL.addDate(row, errors);

        EHR.ETL.fixParticipantId(row, errors);
        EHR.ETL.fixSurgMajor(row, errors);

        //allows dataset-specific code
        if(EHR.ETL.byQuery[helper.getQueryName()])
            EHR.ETL.byQuery[helper.getQueryName()](row, errors);

        helper.logDebugMsg('Repaired: '+row);
    },

    fixParticipantId: function (row, errors){
        if (row.hasOwnProperty('Id') && !row.Id){
            row.id = 'MISSING';
            EHR.Server.Utils.addError(errors, 'Id', 'Missing Id', 'ERROR');
        }
    },

    addDate: function (row, errors){
        if (row.hasOwnProperty('date') && !row.Date){
            //row will fail unless we add something in this field
            row.date = new Date();

            EHR.Server.Utils.addError(errors, 'date', 'Missing Date', 'ERROR');
        }
    },

    fixPathCaseNo: function(row, errors, code){
        //we try to clean up the biopsy ID
        var re = new RegExp('([0-9]+)('+code+')([0-9]+)', 'i');

        var match = row.caseno.match(re);
        if (!match){
            EHR.Server.Utils.addError(errors, 'caseno', 'Error in CaseNo: '+row.caseno, 'WARN');
        }
        else {
            //fix the year
            if (match[1].length == 2){
                if (match[1] < 20)
                    match[1] = '20' + match[1];
                else
                    match[1] = '19' + match[1];
            }
            else if (match[1].length == 4){
                //these values are ok
            }
            else {
                EHR.Server.Utils.addError(errors, 'caseno', 'Unsure how to correct year in CaseNo: '+match[1], 'WARN');
                //row.QCStateLabel = errorQC;
            }

            //standardize number to 3 digits
            if (match[3].length != 3){
                var tmp = match[3];
                for (var i=0;i<(3-match[3].length);i++){
                    tmp = '0' + tmp;
                }
                match[3] = tmp;
            }

            row.caseno = match[1] + match[2] + match[3];
        }

    },

    fixResults: function(row, errors){
        //we try to remove non-numeric characters from this field
        if (row.stringResults && !row.stringResults.match(/^[0-9]*$/)){
            //we need to manually split these into multiple rows

            if (row.stringResults.match(/,/) && row.stringResults.match(/[0-9]/)){
                EHR.Server.Utils.addError(errors, 'result', 'Problem with result: ' + row.stringResults, 'WARN');
                row.stringResults = null;
                //row.QCStateLabel = errorQC;
            }
            else {
                //did not find other strings in data
                row.stringResults = row.stringResults.replace('less than', '<');

                var match = row.stringResults.match(/^([<>=]*)[ ]*(\d*\.*\d*)([-]*\d*\.*\d*)([+]*)[ ]*(.*)$/);

                //our old data can have the string modifier either before or after the numeric part
                if (match[4])
                    row.resultOORIndicator = match[4];
                //kinda weak, but we preferentially take the prefix.  should never have both
                if (match[1])
                    row.resultOORIndicator = match[1];

                //these should be ranges
                if(match[3]){
                    row.qualResult = match[2]+match[3];

                    //verify this number isnt numeric
                    if (!isNaN(row.qualResult)){
                        row.result = row.qualResult;
                        row.qualResult = null;
                    }
                }
                else
                    row.result = match[2];

                //if there is a value plus a string, we assume it's units.  otherwise it's a remark
                if (match[5]){
                    if(match[2] && !match[5].match(/[;,]/)){
                        row.units = match[5];
                    }
                    else {
                        if(row.qualResult){
                            row.Remark = match[5];
                        }
                        else {
                            row.qualResult = match[5];
                        }

                    }
                }
            }
        }
        else {
            //this covers the situation where a mySQL string column contained a numeric value without other characters
            row.result = row.stringResults;
            delete row.stringResults;
        }
    },

    fixSampleQuantity: function(row, errors, fieldName){
        fieldName = fieldName || 'quantity';

        //we try to remove non-numeric characters from this field
        if (row[fieldName] && typeof(row[fieldName]) == 'string' && !row[fieldName].match(/^(\d*\.*\d*)$/)){
            //we need to manually split these into multiple rows
            if (row[fieldName].match(/,/)){
                row[fieldName] = null;
                EHR.Server.Utils.addError(errors, fieldName, 'Problem with quantity: ' + row[fieldName], 'WARN');
                //row.QCStateLabel = errorQC;
            }
            else {
                //did not find other strings in data
                row[fieldName] = row[fieldName].replace(' ', '');
                row[fieldName] = row[fieldName].replace('n/a', '');
                row[fieldName] = row[fieldName].replace('N/A', '');
                row[fieldName] = row[fieldName].replace('na', '');
                row[fieldName] = row[fieldName].replace(/ml/i, '');
                row[fieldName] = row[fieldName].replace('prj31f', '');

                //var match = row[fieldName].match(/^([<>~]*)[ ]*(\d*\.*\d*)[ ]*(\+)*(.*)$/);
                var match = row[fieldName].match(/^\s*([<>~]*)\s*(\d*\.*\d*)\s*(\+)*(.*)$/);
                if (match[1] || match[3])
                    row[fieldName+'OORIndicator'] = match[1] || match[3];

                row[fieldName] = match[2];
            }
        }
    },

    fixSurgMajor: function(row, errors){
        if (row.major){
            switch (row.major){
                case true:
                case 'y':
                case 'Y':
                    row.major = 'Yes';
                    break;
                case false:
                case 'n':
                case 'N':
                    row.major = 'No';
                    break;
                default:
                    row.major = null;
            }
        }
    },

    remarkToSoap: function(row, errors){
        //convert existing SOAP remarks into separate cols
        var origRemark = row.remark;
        if(row.remark){
            row.remark = EHR.Server.Utils.trim(row.remark);
            row.remark = row.remark.replace(/^(<>)*/, '');
            row.remark = EHR.Server.Utils.trim(row.remark);

            //find Hx
            var hx = row.remark.match(/hx:(.*);\|/i);
            if (hx){
                row.hx = hx[1];
                row.hx= EHR.Server.Utils.trim(row.hx);
                row.hx= EHR.ETL.cleanLine(row.hx);

                row.remark = row.remark.replace(hx[0], '');
                row.remark = EHR.Server.Utils.trim(row.remark);
                row.remark = row.remark.replace(/^(<>)*/, '');
                row.remark = EHR.Server.Utils.trim(row.remark);
            }

            var s = row.remark.match(/^(.*?)(s:|s\/o:|so:)(.*?)(o:|a:|p1:|p2:)/i);
            if(s){
                row.s = s[3];
                row.s = EHR.Server.Utils.trim(row.s);
                row.s = EHR.ETL.cleanLine(row.s);

                var prefix = s[1];
                row.remark = row.remark.replace(s[0], '');
                if (prefix){
                    row.remark = prefix + row.remark;
                }

                if (s[4])
                    row.remark = s[4] + row.remark;
                row.remark = EHR.Server.Utils.trim(row.remark);
                row.remark = row.remark.replace(/^(<>)*/, '');
                row.remark = EHR.Server.Utils.trim(row.remark);
            }

            var o = row.remark.match(/^o:(.*?)(a:|p1:|p2:)/i);
            if(o){
                row.o = o[1];
                row.o = EHR.Server.Utils.trim(row.o);
                row.o = EHR.ETL.cleanLine(row.o);

                row.remark = row.remark.replace(o[0], '');
                if (o[2])
                    row.remark = o[2] + row.remark;
                row.remark = EHR.Server.Utils.trim(row.remark);
                row.remark = row.remark.replace(/^(<>)*/, '');
                row.remark = EHR.Server.Utils.trim(row.remark);
            }

            var a = row.remark.match(/^a:(.*?)(p:(?=\D)|p1:|p2:|$)/i);
            if(a){
                row.a = a[1];
                row.a = EHR.Server.Utils.trim(row.a);
                row.a = EHR.ETL.cleanLine(row.a);

                row.remark = row.remark.replace(a[0], '');
                if (a[2])
                    row.remark = a[2] + row.remark;
                row.remark = EHR.Server.Utils.trim(row.remark);
                row.remark = row.remark.replace(/^(<>)*/, '');
                row.remark = EHR.Server.Utils.trim(row.remark);
            }

            var p1 = row.remark.match(/(P:|P1:)(.*?)(P2:|$)/i);
            if(p1){
                row.p = p1[2];
                row.p = EHR.Server.Utils.trim(row.p);
                row.p = EHR.ETL.cleanLine(row.p);

                row.remark = row.remark.replace(p1[0], '');
                row.remark = p1[3] + row.remark;
                row.remark = EHR.Server.Utils.trim(row.remark);
                row.remark = row.remark.replace(/^(<>)*/, '');
                row.remark = EHR.Server.Utils.trim(row.remark);
            }

            var p2 = row.remark.match(/p2:(.*)$/i);
            if(p2){
                row.p2 = p2[1];
                if (row.p2){
                    row.p2 = EHR.Server.Utils.trim(row.p2);
                    row.p2 = EHR.ETL.cleanLine(row.p2);
                }

                row.remark = row.remark.replace(p2[0], '');
                row.remark = EHR.Server.Utils.trim(row.remark);
                row.remark = row.remark.replace(/^(<>)*/, '');
            }

            row.remark = EHR.ETL.cleanLine(row.remark);
        }
    },

    cleanLine: function(line){
        line = line.replace(/<>/g, '\n');
        line = line.replace(/\n+/g, '\n');
        line = EHR.Server.Utils.trim(line);
        return line;
    },

    byQuery: {
//        'Behavior Remarks': function(row, errors){
//            EHR.ETL.remarkToSoap(row, errors);
//        },
//
        'Clinical Remarks': function(row, errors){
            EHR.ETL.remarkToSoap(row, errors);
        },

        Biopsies: function(row, errors){
            if(row.caseno)
                EHR.ETL.fixPathCaseNo(row, errors, 'b');
        },

        'Chemistry Results': function(row, errors){
            if(row.stringResults){
                EHR.ETL.fixResults(row, errors);
            }
        },

        'Misc Tests': function(row, errors){
            if(row.stringResults){
                EHR.ETL.fixResults(row, errors);
            }
        },

        Demographics: function(row, errors){

            //the ETL code is going to error if the row is missing a date.
            //since demographics can have a blank date, we remove that:
            if(errors['date']){
                var obj = [];
                LABKEY.ExtAdapter.each(errors['date'], function(e){
                    if(e.message!='Missing Date')
                        obj.push(e);
                }, this);
                errors.date = obj;
            }

        },

        'Hematology Results': function(row, errors){
            if(row.stringResults){
                EHR.ETL.fixResults(row, errors);
            }
        },

        'iStat': function(row, errors){
            if(row.stringResults){
                EHR.ETL.fixResults(row, errors);
            }
        },

        //        'Necropsies': function(row, errors){
//            if(row.caseno)
//                EHR.ETL.fixPathCaseNo(row, errors, 'a|c|e');
//        },

        'Urinalysis Results': function onETL(row, errors){
            if(row.stringResults){
                EHR.ETL.fixResults(row, errors);
            }

            if(row.quantity)
                EHR.ETL.fixSampleQuantity(row, errors);
        }
    }
};