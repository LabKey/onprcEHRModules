/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 5-5-2017   R.Blasa
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
                allowBlank: false,
                label: 'Center Project'
            },
            billingproject: {
                xtype: 'onprc_ehr-projectentryfield',
                label: 'Center Project Billing',
                hidden: false,
                allowBlank: false

            },

            performedby: {
                allowBlank: true,
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
                allowBlank: false,
                columnConfig: {
                    width: 150
                }
            },

            animaldelivery: {
                hidden: false,
                xtype: 'path_delivery',
                label: 'Animal Delivery Requested',
                allowBlank: false,
                columnConfig: {
                    width: 150
                }
            },
            necropsygrade: {
                hidden: false,
                xtype: 'path_billinggrade',
                allowBlank: false,
                columnConfig: {
                    width: 150
                }
            },
            remainingTissues: {
                hidden: false,
                xtype: 'path_approval',
                label: 'Are Remaining Tissues available for distribution?',
                allowBlank: false,
                columnConfig: {
                    width: 150
                }
            },
            necropsylocation: {
                hidden: false,
                xtype: 'path_location',
                label: 'Necropsy Location',
                allowBlank: false,
                columnConfig: {
                    width: 150
                }
            },

            remark: {
                hidden: true

            }
        },
        'study.tissue_samples': {
            weight: {
                editorConfig: {
                    decimalPrecision: 3
                }
            },
            preparation: {
                allowBlank: false,
                lookup: {
                    columns: 'objectid,value,category,code',
                    sort: 'sort_order',
                    filterArray: [LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)]
                }
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
                hidden: false,
                xtype: 'path_billinggrade',
                label: 'Charge Name',
                columnConfig: {
                    width: 250
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
                hidden: false
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
                allowBlank: true,
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