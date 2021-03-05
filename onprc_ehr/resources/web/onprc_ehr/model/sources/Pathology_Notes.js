/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Necropsy_Notes', {

    byQuery: {

        'ehr.encounter_summaries': {
            Id: {
                hidden: true
            },
            date: {
                hidden: true
            },
            category: {
                defaultValue: 'Pathology Notes',
                hidden: true
            },
            RemarkHistory: {

                hidden: true
            },
            remark: {
                height: 300,
                editorConfig: {
                    fieldLabel: 'Notes',
                    width: 1000
                }
            }
        },
        //Added: 10-12-2017 R.Blasa
        'ehr.encounter_participants': {
            Id: {
                hidden: false,
                allowBlank: false
            },
            userid: {
                hidden: true,
                columnConfig: {
                    width: 200
                }
            },
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
                        innerTpl: '{[values.username + (values.username ? " (" + values.LastName + (values.FirstName ? ", " + values.FirstName : "") + ")" : "")]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                }
            },
            role: {
                allowBlank: false,
                columnConfig: {
                    width: 200
                }
            },
            comment: {
                hidden: true
            }
        },

        'study.histology': {
            codesRaw: {
               header: 'Snomed Codes'
            }
       },
        'onprc_ehr.encounter_summaries_remarks': {
            Id: {
                hidden: true
            },
            date: {
                hidden: true
            },
            category: {
                defaultValue: 'Pathology Notes',
                hidden: true
            },
            createdBy: {

                hidden: true
            },
            modifiedBy: {

                hidden: true
            },
            remark: {
                height: 300,
                editorConfig: {
                    fieldLabel: 'Notes - History',
                    width: 1000
                }
            }
        }

    }
});