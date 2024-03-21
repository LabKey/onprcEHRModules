/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 2-24-2021
EHR.model.DataModelManager.registerMetadata('Biopsy_Notes', {

    byQuery: {

        'study.histology': {
            codesRaw: {
                header: 'Snomed Codes'
            }
        },

        'study.encounters': {
            project: {
                xtype: 'onprc_ehr-projectentryfield'
            },
            remark: {
                defaultValue: 'CLINICAL HISTORY: \n\n\nGROSS DESCRIPTION: \n\n\nHISTOLOGIC DIAGNOSIS: \n\n\nCOMMENTS: \n\n\n',
                hidden: false
              }
        },
        //Added: 10-7-2022 R.Blasa
        'ehr.encounter_participants': {

            username: {
                hidden: false,
                allowBlank: false,
                columnConfig: {
                    width: 200
                },
                lookup: {
                    xtype: 'labkey-combo',
                    schemaName: 'onprc_ehr',
                    queryName: 'Reference_StaffNames',
                    keyColumn: 'username',
                    displayColumn: 'username',
                    filterArray: [
                        LABKEY.Filter.create('DisableDate', null, LABKEY.Filter.Types.ISBLANK),
                        LABKEY.Filter.create('Type', 'Necropsy', LABKEY.Filter.Types.EQUAL)],
                    columns: 'username,FirstName,LastName,Type,DisableDate',
                    sort: 'username'

                },
                editorConfig: {
                    anyMatch: true,
                    listConfig: {
                        innerTpl: '{[LABKEY.Utils.encodeHtml(values.username + (values.username ? " (" + values.LastName + (values.FirstName ? ", " + values.FirstName : "") + ")" : ""))]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                }
            }

        },


        'study.pathologyDiagnoses': {
            codesRaw: {
                header: 'Snomed Codes'
            }
        }
    }
});