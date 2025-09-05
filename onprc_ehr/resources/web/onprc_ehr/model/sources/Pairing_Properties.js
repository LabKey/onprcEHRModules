/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created 6-7-2016  R.Blasa
EHR.model.DataModelManager.registerMetadata('Pairing_Properties', {
    allQueries: {

    },
    byQuery: {

        'study.pairings': {

            outcome: {
                allowBlank: false,
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }
            },


            goal: {
                allowBlank: false,
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }
            },

            eventtype: {
                columnConfig: {
                    width: 250
                },
                editorConfig: {
                    caseSensitive: false,
                    anyMatch: true,
                    listConfig: {
                        innerTpl: '{[(values.category ? "<b>" + LABKEY.Utils.encodeHtml(values.category) + ":</b> " : "") + LABKEY.Utils.encodeHtml(values.value)]}',
                        getInnerTpl: function () {
                            return this.innerTpl;
                        }
                    }
                },
                lookup: {
                    xtype: 'combobox',
                    schemaName: 'ehr_Lookups',
                    queryName: 'pairingeventsAll',
                    columns: 'value,category,sort_order,date_disabled',
                    keyColumn: 'value',
                    displayColumn: 'value',
                    sort: 'category,value,sort_order',
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }
            },


            enddate: {
                hidden: false
            },

            separationreason: {
                allowBlank: true,

                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }

            },
            observation: {
                allowBlank: true,
                columnConfig: {
                    width: 200
                },
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }

            },

            remark2: {
                    xtype: 'textareafield',
                    width: 400,

                },
            room: {
                allowBlank: false,
              },
            remark: {
                    width: 400
                },

            }

    }
});