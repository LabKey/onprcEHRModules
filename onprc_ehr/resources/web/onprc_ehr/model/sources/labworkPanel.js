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
         date: {
                xtype: 'xdatetime',
                extFormat: LABKEY.extDefaultDateTimeFormat,
                allowBlank: false,
                editorConfig: {
                    defaultHour: 8,
                    defaultMinutes: 0
                },
                getInitialValue: function (v, rec) {
                    if (v)
                        return v;

                    var ret = Ext4.Date.clearTime(new Date());
                    ret = Ext4.Date.add(ret, Ext4.Date.DAY, 1);
                    ret.setHours(8);
                    return ret;
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