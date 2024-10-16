/*
 * Copyright (c) 2014-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created 2-5-2016 Blasa
EHR.model.DataModelManager.registerMetadata('LabworkPanel', {
    allQueries: {

    },
    byQuery: {
        'study.clinpathRuns': {
            servicerequested: {
                allowBlank: false,
                columnConfig: {
                    width: 250
                },
                lookup: {
                   xtype: 'labkey-combo',
                   schemaName: 'onprc_ehr',
                  queryName: 'labServiceRequest_Active',
                  keyColumn: 'servicename',
                  columns: '*',
                  sort: 'chargetype,servicename,outsidelab'
                },
                editorConfig: {
                    anyMatch: true,
                    listConfig: {
                        innerTpl: '{[(values.chargetype ? "<b>" + LABKEY.Utils.encodeHtml(values.chargetype) + ":</b> " : "") + LABKEY.Utils.encodeHtml(values.servicename + (values.outsidelab ? "*" : ""))]}',
                            getInnerTpl: function () {
                            return this.innerTpl;
                        }
                    }
                }
            },
            vet: {
            hidden: false,
            allowBlank: false,
            columnConfig: {
                width: 200
            },
            lookup: {
                xtype: 'labkey-combo',
                schemaName: 'onprc_ehr',
                queryName: 'Labwork_Requestor_Vets',
                keyColumn: 'userId',
                displayColumn: 'username',
                filterArray: [
                    LABKEY.Filter.create('DisableDate', null, LABKEY.Filter.Types.ISBLANK)],
                columns: 'username,FirstName,LastName,Type,DisableDate,userId',
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
        },



            performedby: {
                defaultValue: LABKEY.Security.currentUser.displayName ,
                hidden: false
            }

        },
        'ehr.requests': {
            priority: {
                defautValue: 'Routine',
               hidden: true
            }

        }
    }
});