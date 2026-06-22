/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created 6-7-2016  R.Blasa
EHR.model.DataModelManager.registerMetadata('Bulk_Pairing_Properties', {
    allQueries: {

    },
    byQuery: {

        'study.pairings': {

            outcome: {
                hidden: true
            },
            Id: {
                allowBlank: false,
                columnConfig: {
                    width: 100
                }
            },
            infant_id: {
                hidden: true
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
                    queryName: 'pairingstarttype',
                    columns: 'value,category,sort_order,date_disabled',
                    keyColumn: 'value',
                    displayColumn: 'value',
                    sort: 'category,value,sort_order',
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK),
                        LABKEY.Filter.create('category', 'STF Clinical', LABKEY.Filter.Types.EQUAL)
                    ]
                }
            },
            outcome: {
                hidden: true
            },
            goal: {
                hidden: true
            },
            endeventType: {

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
                        queryName: 'pairingendtypes',
                        columns: 'value,category,sort_order,date_disabled',
                        keyColumn: 'value',
                        displayColumn: 'value',
                        sort: 'category,value,sort_order',
                        filterArray: [
                            LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK),
                            LABKEY.Filter.create('category', 'STF Clinical', LABKEY.Filter.Types.EQUAL)
                        ]
                    }

            },
           enddate: {
                hidden: false
            },
            separationreason: {
                hidden: true
            },
            observation: {
                hidden: true
            },

            remark2: {
                xtype: 'textareafield',
                columnConfig: {
                    width: 200
                }
            },
            room: {
                allowBlank: false,
                columnConfig: {
                    width: 130
                }
            },
            cage: {
                allowBlank: false,
                columnConfig: {
                    width: 100
                }
            },
            priorgrouphousing: {
                hidden: true
            },
            category: {
                allowBlank: false,
                columnConfig: {
                    width: 150
                },
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK),
                        LABKEY.Filter.create('value', 'STF Clinical', LABKEY.Filter.Types.EQUAL)
                    ]
                }
            },
            other_infant: {
                hidden: true
            },
            lowestcage: {
                hidden: true
            },
            remark: {
                xtype: 'textareafield',
                columnConfig: {
                    width: 200
                }
            }

        }

    }
});