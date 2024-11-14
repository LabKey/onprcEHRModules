/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * The default metadata applied to all queries when using getTableMetadata().
 * This is the default metadata applied to all queries when using getTableMetadata().  If adding attributes designed to be applied
 * to a given query in all contexts, they should be added here
 */
EHR.model.DataModelManager.registerMetadata('Default', {
    byQuery: {

        //Kolli1 3/19: Added this code to display the description field in the protocol details data entry screen. The Description field is hidden in the core. (Defaults.js)
        // To overwrite the core code, this snippet is added on the onprc side
        'ehr.protocol': {
            description: {
                hidden: false,
                label: "Notes"
            }
        },

        //Added by Kolli, 8/14/2024. Make the enddate not required globally,
        // but added the validation code to force the enddate for all meds except Medroxyprojesterone and Dite - Multivitamins
        // Refer tkt #
        'study.treatment_order': {
            enddate: {
                xtype: 'xdatetime',
                allowBlank: true,
                extFormat: LABKEY.extDefaultDateTimeFormat,
                editorConfig: {
                    defaultHour: 23,
                    defaultMinutes: 59
                }
            }
        },

        'study.blood' : {
            tube_vol: {
                hidden: true
            },
            num_tubes: {
                hidden: true
            },
            quantity: {
                xtype: 'numberfield'
            }
        },

        //Added: 1-27-2017  R.Blasa
        'study.pregnancyConfirmation': {
            gestation_days: {
                columnConfig: {
                    width: 100
                }
            }

        },

        //Added: 10-6-2022  R.Blasa
        'ehr.tasks': {
            assignedto: {
                useNull: true,
                facetingBehaviorType: "AUTO",
                getInitialValue: function(val, rec){
                    LDK.Assert.assertNotEmpty('No dataEntryPanel for model', rec.dataEntryPanel);
                    return val || rec.dataEntryPanel.formConfig.defaultAssignedTo || LABKEY.Security.currentUser.id
                },
                xtype: 'onprc_ehr-usersandgroupscombo',
                lookup: {
                    sort: 'Type,DisplayName'
                },
                editorConfig: {listWidth: 200}
            },
        },

        //Added: 12-27-2017  R.Blasa
        'study.Arrival': {
            date: {
                xtype: 'xdatetime',
                allowBlank: false,
                extFormat: LABKEY.extDefaultDateTimeFormat,
                columnConfig: {
                    width: 150
                }
           },
            //Added: 5-3-2018 R.Blasa
            acquisitionType: {
                hidden: false,
                allowBlank: false
            }
        },

        //Added: 12-26-2017  R.Blasa
        'study.Assignment': {

            date: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat,
                columnConfig: {
                    width: 100
                }
            },
            enddate: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat,
                columnConfig: {
                    width: 100
                }
            },

            projectedRelease: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat,
                columnConfig: {
                    width: 100
                }
            },

            projectedReleaseCondition: {
                columnConfig: {
                    width: 200
                }
            },
            releaseCondition: {
                columnConfig: {
                    width: 200
                } ,
                lookup: {
                filterArray: [
                    LABKEY.Filter.create('datedisabled', null, LABKEY.Filter.Types.ISBLANK)

                ]

            }
         },

            assignCondition: {
                columnConfig: {
                    width: 200
                }

            },


            projectedRelease: {
                    xtype: 'datefield',
                    extFormat: LABKEY.extDefaultDateFormat,
                    columnConfig: {
                        width: 100
                    }
               }

    },

        'study.weight': {
            project: {
                hidden: true
            },
            account: {
                hidden: true
            },
            performedby: {
                allowBlank: false,
                lookup: {
                    schemaName: 'core',
                    queryName: 'users',
                    keyColumn: 'DisplayName',
                    displayColumn: 'DisplayName',
                    columns: 'UserId,DisplayName,FirstName,LastName',
                    sort: 'Type,DisplayName'
                }
            },

            'id/curlocation/location': {
                shownInGrid: true
            },
            remark: {
                shownInGrid: true
            },
            weight: {
                allowBlank: false,
                useNull: true,
                editorConfig: {
                    allowNegative: false,
                    decimalPrecision: 4
                }
            }
        },
        //Added: 11-20-2017   R.blasa

        'study.clinremarks': {

            CEG_Plan: {
                formEditorConfig: {
                    xtype: 'onprc_ehr-CEG_Plantextarea'
                },
                height: 52
            }
        },

        //Added: 12-27-2017   R.blasa

        'study.flags': {

            RequestedBy: {
                columnConfig: {
                    width: 100
                }

            },
            ScheduleNecropsy: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat,
                columnConfig: {
                    width: 150
                }

            },
            TargetEndDate: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat,
                columnConfig: {
                    width: 150
                }
            }

        }

    }
});

EHR.model.DataModelManager.registerMetadata('Request', {
    byQuery: {
        'study.blood' : {
            quantity: {
                xtype: 'numberfield'
            },
            tube_vol: {
                nullable: true
            },
            num_tubes: {
                nullable: true
            }
        }
    }


});
