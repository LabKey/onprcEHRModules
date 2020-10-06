/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created: 7-23-2018 R.Blasa
EHR.model.DataModelManager.registerMetadata('Biopsy_Staff', {

    byQuery: {

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
                        LABKEY.Filter.create('Type', 'Surgery', LABKEY.Filter.Types.EQUAL)],
                    columns: 'username,FirstName,LastName,Type,DisableDate,displayname',
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
        }


    }
});