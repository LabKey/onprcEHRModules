/*
 * Copyright (c) 2012 LabKey Corporation
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
 * @depreciated
 * This was originally used to transform data being imported from the legacy mySQL system.
 * It should be written out of the validation script at some point.
 */
EHR.ETL = {
    fixRow: function(row, errors, scriptContext){
        //inserts a date if missing
        EHR.ETL.addDate(row, errors);

        EHR.ETL.fixParticipantId(row, errors);

        if (row.project)
            EHR.ETL.fixProject(row, errors);

        //allows dataset-specific code
        if(EHR.ETL.byQuery[scriptContext.queryName])
            EHR.ETL.byQuery[scriptContext.queryName](row, errors, scriptContext);

        if(scriptContext.verbosity > 0)
            console.log('Repaired: '+row);
    },
    fixProject: function(row, errors){
        //sort of a hack.  since mySQL doesnt directly store project for these records, we need to calculate this in the ETL using group_concat
        // 00300901 is a generic WNPRC project.  if it's present with other projects, it shouldnt be.
        if(row.project && row.project.match && (row.project.match(/,/))){
            row.project = row.project.replace(/,00300901/, '');
            row.project = row.project.replace(/00300901,/, '');
        }

        //i think the ETL can return project as a string
        if (row.project && !/^\d*$/.test(row.project)){
            EHR.Server.Validation.addError(errors, 'project', 'Bad Project#: '+row.project, 'ERROR');
            row.project = null;
            //row.QCStateLabel = errorQC;
        }
    },
    fixParticipantId: function (row, errors){
        if (row.hasOwnProperty('Id') && !row.Id){
            row.id = 'MISSING';
            EHR.Server.Validation.addError(errors, 'Id', 'Missing Id', 'ERROR');
        }
    },
    addDate: function (row, errors){
        if (row.hasOwnProperty('date') && !row.Date){
            //row will fail unless we add something in this field
            row.date = new java.util.Date();

            EHR.Server.Validation.addError(errors, 'date', 'Missing Date', 'ERROR');
        }
    },
    fixPathCaseNo: function(row, errors, code){
        //we try to clean up the biopsy ID
        var re = new RegExp('([0-9]+)('+code+')([0-9]+)', 'i');

        var match = row.caseno.match(re);
        if (!match){
            EHR.Server.Validation.addError(errors, 'caseno', 'Error in CaseNo: '+row.caseno, 'WARN');
            //row.QCStateLabel = errorQC;
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
                EHR.Server.Validation.addError(errors, 'caseno', 'Unsure how to correct year in CaseNo: '+match[1], 'WARN');
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
    fixChemValue: function(row, errors){
        //we try to remove non-numeric characters from this field
        if (row.stringResults && !row.stringResults.match(/^[0-9]*$/)){
            //we need to manually split these into multiple rows

            if (row.stringResults.match(/,/) && row.stringResults.match(/[0-9]/)){
                EHR.Server.Validation.addError(errors, 'result', 'Problem with result: ' + row.stringResults, 'WARN');
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
                if(match[3])
                    row.qualResult = match[2]+match[3];
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
                EHR.Server.Validation.addError(errors, fieldName, 'Problem with quantity: ' + row[fieldName], 'WARN');
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
//    fixDrugUnits: function(row, errors){

//    },
    fixHemaMiscMorphology: function(row, errors){
        var c = row.morphology.split('_');
        //changes by request of molly
        //reverted.  will handle during data entry
//        if(c[0]=='TOXIC GRANULES')
//            c[0] = 'TOXIC CHANGE';

        row.morphology = c[0];
        if (c[1])
            row.score = c[1];
    },
//    fixNecropsyCase: function(row, errors){
//        //we try to clean up the caseno
//        var re = /([0-9]+)(a|c)([0-9]+)/i;
//        var match = row.caseno.match(re);
//        if (!match){
//            EHR.Server.Validation.addError(errors, 'caseno', 'Malformed CaseNo: '+row.caseno, 'WARN');
//        }
//        else {
//            //fix the year
//            if (match[1].length == 2){
//                //kind of a hack. we just assume records wont be that old
//                if (match[1] < 20)
//                    match[1] = '20' + match[1];
//                else
//                    match[1] = '19' + match[1];
//            }
//            else if (match[1].length == 4){
//                //these values are ok
//            }
//            else {
//                EHR.Server.Validation.addError(errors, 'caseno', 'Unsure how to correct year in CaseNo: '+match[1], 'WARN');
//            }
//
//            //standardize number to 3 digits
//            if (match[3].length != 3){
//                var tmp = match[3];
//                for (var i=0;i<(3-match[3].length);i++){
//                    tmp = '0' + tmp;
//                }
//                match[3] = tmp;
//            }
//            row.caseno = match[1] + match[2] + match[3];
//        }
//    },
    fixSurgMajor: function(row, errors){
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
    },
    remarkToSoap: function(row, errors){
        //convert existing SOAP remarks into 3 cols
        var origRemark = row.remark;
        if(row.remark && row.remark.match(/(^s\/o: )/)){
            var so = row.remark.match(/(^s\/o: )(.*?)( a:| p:| a\/p:)/);
            if(!so){
                //this is a remark beginning with s/o:, but without a or p
                row.so = row.remark;
                row.remark = null;
            }
            else {
                row.so = so[2];
                row.so = row.so.replace(/^\s+|\s+$/g,"");

                row.remark = row.remark.replace(/^s\/o: /, '');
                row.remark = row.remark.replace(so[2], '');

                var a = row.remark.match(/^( a:| a\/p:)(.*?)( p:|$)/);
                if(a){
                    if(a[2]){
                        row.a = a[2];
                        row.a = row.a.replace(/^\s+|\s+$/g,"");

                        row.remark = row.remark.replace(/^( a:| a\/p:)/, '');
                        row.remark = row.remark.replace(a[2], '');
                    }
//                    else {
//                        console.log('a not found')
//                        console.log(origRemark);
//                    }
                }
//                else {
//                    console.log('a not found')
//                    console.log(origRemark);
//                }

                //apparently some rows can lack an assessment
                var p = row.remark.match(/^( p: )(.*)$/);
                if(p){
                    if(p[2]){
                        row.p = p[2];
                        row.p = row.p.replace(/^\s+|\s+$/g,"");

                        row.remark = row.remark.replace(/^( p: )/, '');
                        row.remark = row.remark.replace(p[2], '');
                        row.remark = row.remark.replace(/^\s+|\s+$/g,"");
                    }
//                    else {
//                        console.log('p not found')
//                        console.log(origRemark);
//                    }
                }

            }

            if(row.remark){
                console.log('REMARK REMAINING:');
                console.log(row.remark)
            }
        }
    },

    byQuery: {
        'Bacteriology Results': function(row, errors){
            //this is a hack so mySQL records go in.
            EHR.Server.Validation.antibioticSens(row, errors);

        },

        'Behavior Remarks': function(row, errors){
            EHR.ETL.remarkToSoap(row, errors);
        }
    },

    Biopsies: function(row, errors){
        if(row.caseno)
            EHR.ETL.fixPathCaseNo(row, errors, 'b');
    },

    'Chemistry Results': function(row, errors){
        if(row.stringResults){
            EHR.ETL.fixChemValue(row, errors);
        }
    },

    'Clinical Encounters': function(row, errors){
        //we grab the first sentence as title
        if(row.type == 'Surgery' && !row.title && row.remark && row.remark.length > 200){
            var match = row.remark.match(/^(.*?)\./);
            if(match && match[1] && match[1].length < 35){
                var title = match[1];

                if(!title.match(/^\(con/) && !title.match(/^cont/)){
                    row.title = title;
                }
            }
        }

        EHR.ETL.fixSurgMajor(row, errors);

        //applies to biopsy / necropsy
        if(row.caseno){
            var code;
            if(row.type=='Necropsy')
                code='a|c|e';
            else if (row.type == 'Biopsy')
                code = 'b';

            if(code)
                EHR.ETL.fixPathCaseNo(row, errors, code);
        }

    },

    'Clinical Remarks': function(row, errors){
        EHR.ETL.remarkToSoap(row, errors);
    },

    'Clinpath Runs': function(row, errors){
        if(row.sampleQuantity)
            EHR.ETL.fixSampleQuantity(row, errors, 'sampleQuantity');
    },

    Demographics: function(row, errors){
        var species = EHR.Server.Validation.getSpecies(row, errors);
        row.species = row.species || species;

        //the ETL code is going to error if the row is missing a date.
        //since demographics can have a blank date, we remove that:
        if(errors['date']){
            var obj = [];
            Ext.each(errors['date'], function(e){
                if(e.message!='Missing Date')
                    obj.push(e);
            }, this);
            errors.date = obj;
        }

    },

    'Hematology Morphology': function(row, errors){
        EHR.ETL.fixHemaMiscMorphology(row, errors);
    },

    'Hematology Results': function(row, errors){
        if(row.stringResults){
            EHR.ETL.fixChemValue(row, errors);
        }
    },

    'Necropsies': function(row, errors){
        if(row.caseno)
            EHR.ETL.fixPathCaseNo(row, errors, 'a|c|e');
    },

    Surgeries: function onETL(row, errors){
        EHR.ETL.fixSurgMajor(row, errors);
    },

    'TB Tests': function(row, errors){
        //NOTE: hyphen means 'not going to perform'
        //    if (row.result1 == '-') row.result1 = 0;
        //    if (row.result2 == '-') row.result2 = 0;
        //    if (row.result3 == '-') row.result3 = 0;

        if (row.result1 == '+') row.result1 = 5;
        if (row.result2 == '+') row.result2 = 5;
        if (row.result3 == '+') row.result3 = 5;
    },

    'Treatment Orders': function onETL(row, errors){
        if(row.code == '00000000'){
            row.code = null;
            row.qualifier = row.meaning;
        }

        //transform non-SNOMED into true SNOMED
        switch (row.code){
            case 'c-f0000a':
                row.qualifier = 'Soak chow in water';
                row.code = 'c-f0000';
                break;
            case 'c-f0000b':
                row.qualifier = 'Soak chow in ensure';
                row.code = 'c-f0000';
                break;
            case 'c-f0000c':
                row.qualifier = 'Zupreem';
                row.code = 'c-f0000';
                break;
            case 'c-f0000d':
                row.qualifier = 'softies';
                row.code = 'c-f0000';
                break;
            case 'c-f0000e':
                row.qualifier = 'softies';
                row.code = 'c-f0000';
                break;
            case 'c-f0000f':
                row.qualifier = 'PB Sand / Fig Newton / Fruit';
                row.code = 'c-f0000';
                break;
            case 'c-f0000g':
                row.qualifier = 'PB Sand / Fig Newton';
                row.code = 'c-f0000';
                break;
            case 'c-f0000h':
                row.qualifier = 'PB Sand';
                row.code = 'c-f0000';
                break;
            case 'c-f0000i':
                row.qualifier = 'PB Sand / Yogurt Sand';
                row.code = 'c-f0000';
                break;
            case 'c-f0000j':
                row.qualifier = 'yogurt';
                row.code = 'c-f0000';
                break;
            case 'c-f0000k':
                row.qualifier = 'Fruit';
                row.code = 'c-f0000';
                break;
            case 'c-f2300a':
                row.qualifier = 'Ensure';
                row.code = 'c-f2300';
                break;
            case 'c-f2300-':
                //row.qualifier = '';
                row.code = 'c-f2300';
                break;
            case 'w-10068a':
                row.qualifier = 'Animal Parade Gummi';
                row.code = 'w-10068';
                break;
            case 'w-10068b':
                row.qualifier = 'Solaray Chewable';
                row.code = 'w-10068';
                break;
            case 'f-61e1fa':
                row.qualifier = 'Primadophilus chewable tablet';
                row.code = 'f-61e1f';
                break;
            case 'f-61e1fb':
                row.qualifier = 'Primadophilus powder';
                row.code = 'f-61e1f';
                break;
            case 'f-61e1f-':
                row.qualifier = 'Yakult';
                row.code = 'f-61e1f';
                break;


            case 'c-60187':
                row.qualifier = 'Rimadyl';
                break;
            case 'c-d1467':
                row.qualifier = 'Flunixin Meglumine (Banamine)';
                break;
            case 'c-60111':
                row.qualifier = 'Tramadol';
                break;
            case 'c-54221':
                row.qualifier = 'Penicillin';
                break;
            case 'c-52340':
                row.qualifier = 'Tylosin tartrate (Tylan)';
                break;
            case 'c-84540':
                row.qualifier = 'Immodium';
                break;
            case 'c-a1210':
                row.qualifier = 'Progesterone preparation';
                break;
            case 'c-622b0':
                row.qualifier = 'Clomicalm';
                break;
            case 'c-680d0':
                row.qualifier = 'Epinephrine';
                break;
            case 'c-71064':
                row.qualifier = 'tumil-K';
                break;
            case 'w-10192':
                row.qualifier = 'Supplemental Enrichment';
                break;
        }

        if(row.vol_units == 'ml')
            row.vol_units = 'mL';
        if(row.vol_units == 'capsules')
            row.vol_units = 'capsule(s)';
        if(row.vol_units == 'pieces')
            row.vol_units = 'piece(s)';
        if(row.vol_units == 'tablets')
            row.vol_units = 'tablet(s)';

        if(row.conc_units == 'mg/ml')
            row.conc_units = 'mg/mL';
        if(row.conc_units == 'IU/ml')
            row.conc_units = 'IU/mL';
        if(row.conc_units == 'units/ml')
            row.conc_units = 'units/mL';
        if(row.conc_units == 'mEq/ml')
            row.conc_units = 'mEq/mL';

        if(row.amount_units == 'ml')
            row.amount_units = 'mL';
        if(row.amount_units == 'NULL')
            row.amount_units = null;


        row.meaning = row.meaning || row.snomedMeaning || null;

        row.performedby = row.performedby || row.userid || null;

    },

    'Urinalysis Results': function onETL(row, errors){
        if(row.stringResults){
            EHR.ETL.fixChemValue(row, errors);
        }

        if(row.quantity)
            EHR.ETL.fixSampleQuantity(row, errors);
    }
};