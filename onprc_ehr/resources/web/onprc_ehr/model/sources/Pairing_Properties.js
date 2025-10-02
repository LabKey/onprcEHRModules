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
                allowBlank: true,
                columnConfig: {
                    width: 160
                },
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }
            },
            Id: {
                allowBlank: false,
                columnConfig: {
                    width: 100
                }
            },
            infant_id: {
                xtype: 'onprc_ehr-pairedinfantentryfield',
                allowBlank: true,
                columnConfig: {
                    width: 120
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
                    queryName: 'pairingstarttype',
                    columns: 'value,category,sort_order,date_disabled',
                    keyColumn: 'value',
                    displayColumn: 'value',
                    sort: 'category,value,sort_order',
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }
            },


            goal: {
                allowBlank: true,
                header: 'Divider Goal',
                columnConfig: {
                    width: 170
                },
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }
            },

            endeventType: {
                columnConfig: {
                    width: 180
                },
                lookup: {
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
                columnConfig: {
                    width: 160
                },
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }

            },
            observation: {
                allowBlank: true,
                columnConfig: {
                    width: 250
                },
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }
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
            housingtype: {
                allowBlank: true,
                columnConfig: {
                    width: 180
                }
            },
            category: {
                allowBlank: false,
                columnConfig: {
                    width: 200
                }
            },
            other_infant: {
                xtype: 'onprc_ehr-pairedinfantentryfield',
                allowBlank: true,
                header: 'Other Infant ID',     // should display the infant
                columnConfig: {
                    width: 160
                }
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