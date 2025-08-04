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

            eventtype: {
                editorConfig: {
                    xtype: 'onprc_ehr-pairingcombo',
                    defaultSubset: 'divider_change'  //Use the category name here
                },
                columnConfig: {
                    width: 200
                }
            },


            goal: {
                allowBlank: false,
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
                editorConfig: {
                    xtype: 'onprc_ehr-pairingcombo',
                    defaultSubset: 'pairing_endtype'
                },
                columnConfig: {
                    width: 200
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
                    width: 170
                },
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }
            },
            lowestcage: {
                    xtype: 'onprc_ehr-pairedidentryfield',
                    // header:'Other ID',
                    columnConfig: {
                    width: 200
                    }
                },
            other_IDs: {
                xtype: 'onprc_ehr-paireddamdentryfield',
                header:'Other IDs',     // should display the infant's dam
                columnConfig: {
                    width: 200
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
            prior_group_housing: {
                allowBlank: true,
                columnConfig: {
                    width: 100
                }
            },

            duration: {
                xtype: 'onprc_ehr-durationentryfield',
                allowBlank:true,
                columnConfig: {
                    width: 100
                }
            },
            other_infant: {
                xtype: 'onprc_ehr-pairedinfantentryfield',
                header: 'Infant ID',     // should display the infant
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