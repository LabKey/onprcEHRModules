/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 1-21-2021  R.Blasa
EHR.model.DataModelManager.registerMetadata('PathTissues', {
    allQueries: {
    },
    byQuery: {
        'study.encounters': {
            type: {
                defaultValue: 'Tissues',
                hidden: true
            },
            chargetype: {
                defaultValue: 'DCM: Pathology Services',
                hidden: true
            },
            date: {
                xtype: 'xdatetime',
                header: 'Start Date',
                extFormat: LABKEY.extDefaultDateTimeFormat,
                editorConfig: {
                    dateFormat: LABKEY.extDefaultDateFormat,
                    timeFormat: 'H:i'
                }
            },
            instructions: {
                hidden: false,
                height: 50,
                label: 'Preferred Necropsy date range',
                columnConfig: {
                    width: 70
                }
            },
            enddate: {
                hidden: true
            },
            project: {
                xtype: 'onprc_ehr-projectentryfield',
                header: 'Center Project assigned'
            },
            billingproject: {
                xtype: 'onprc_ehr-projectentryfield',
                label: 'Center Project Billing',
                hidden: false

            },
            performedby: {
                hidden: true
            },
            procedureid: {
                defaultValue: 1082,
                hidden: true
            },
            caseno: {
                hidden: true
            },
            fastingtype: {
                hidden: false,
                label: 'What type of fast would you like to request?',
                xtype: 'path_Fasting',
                columnConfig: {
                    width: 150
                }
            },

            animaldelivery: {
                hidden: false,
                xtype: 'path_delivery',
                label: 'Animal Delivery Requested',
                columnConfig: {
                    width: 150
                }
            },
            necropsygrade: {
                hidden: false,
                xtype: 'path_billinggrade',
                columnConfig: {
                    width: 150
                }
            },
            remainingTissues: {
                hidden: false,
                xtype: 'path_approval',
                label: 'Are Remaining Tissues available for distribution?',
                columnConfig: {
                    width: 150
                }
            },
            necropsylocation: {
                hidden: false,
                xtype: 'path_location',
                label: 'Necropsy Location',
                columnConfig: {
                    width: 150
                }
            },

            remark: {
                hidden: true

            }
        },
        'ehr.requests': {
            remark: {
                label: 'Contact Phone # ',
                width: 300,
                height: 20,
                hidden: false
            }

        },
        'onprc_billing.miscCharges': {
            Id: {
                allowBlank: true,
                nullable: true
            },
            chargetype: {
                defaultValue: 'DCM: Pathology Services'
            },
            chargeId: {
                allowBlank: false,
                nullable: false,
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('active', true, LABKEY.Filter.Types.EQUAL),
                        LABKEY.Filter.create('category', 'Pathology', LABKEY.Filter.Types.EQUAL),
                        LABKEY.Filter.create('rowid', '4484;4485;4486;4487;4488;4489;5296;5297;5298;4491;4492', LABKEY.Filter.Types.EQUALS_ONE_OF)
                    ]
                }
            },
        },
        'study.tissueDistributions': {

            date: {
                hidden: false
            },

            project: {
                xtype: 'onprc_ehr-projectentryfield',
                label: 'Center Project'

            },

            requestcategory: {
                hidden: true
            },
            recipient: {
                columnConfig: {
                    width: 150
                }
            },
            sampletype: {
                columnConfig: {
                    width: 200
                }
            },
            performedby: {
                hidden: true
            },
            tissue: {
                columnConfig: {
                    width: 250
                }
            },

            remark: {
                header: 'Comments',
                hidden: false,
                columnConfig: {
                    width: 250
                }
            }

        }

    }
});