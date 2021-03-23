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
                defaultValue: 'Necropsy',
                hidden: true
            },
            chargetype: {
                defaultValue: 'DCM: Pathology Services',
                hidden: true
            },
            date: {
                xtype: 'xdatetime',
                header: 'Start Date',
                extFormat: 'Y-m-d H:i',
                defaultValue: (new Date()).format('Y-m-d 8:00')
            },
            enddate: {
                xtype: 'xdatetime',
                header: 'Ending Date',
                extFormat: 'Y-m-d H:i',
                defaultValue: (new Date()).format('Y-m-d 8:00'),
                hidden: false
            },
            project: {
                xtype: 'onprc_ehr-projectentryfield',
                header: 'Center Project assigned'
            },
            billingproject: {
                xtype: 'onprc_ehr-projectentryfield',
                label: 'Center Project Billing'

            },
            performedby: {
                hidden: true
            },
            procedureid: {
                defaultValue: 1082,
                hidden: true
            },
            instructions: {
                hidden: true
            },
            caseno: {
                hidden: true
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
        'study.tissueDistributions': {

            date: {
                xtype: 'xdatetime',
                extFormat: 'Y-m-d H:i',
                defaultValue: (new Date()).format('Y-m-d 8:00')
            },
            project: {
                xtype: 'onprc_ehr-projectentryfield',
                label: 'Center Project'

            },
            requestCategory: {
                columnConfig: {
                    width: 150
                }
            },
            recipient: {
                columnConfig: {
                    width: 150
                }
            },
            sampleType: {
                columnConfig: {
                    width: 100
                }
            },
            tissue: {
                columnConfig: {
                    width: 250
                }
            },
            deliveryLoc: {
                xtype: 'path_delivery',
                columnConfig: {
                    width: 150
                }
            },
            availdistribution: {
                xtype: 'path_approval',
                columnConfig: {
                    width: 100

                }
            },
            tissueLoc: {
                xtype: 'path_tissueloc',
                header: 'Necropsy Location',
                columnConfig: {
                    width: 150
                }
            },

            fasting: {
                xtype: 'path_Fasting',
                columnConfig: {
                    width: 150
                }
            },
            perfusion: {
                xtype: 'path_preparation',
                columnConfig: {
                    width: 90
                }
            },
            prioritylevel: {
                xtype: 'path_priority',
                columnConfig: {
                    width: 100
                }
            },
            remark: {
                header: 'Comments',
                hidden: false,
                columnConfig: {
                    width: 250
                }
            },
            // billingcodes: {
            //     xtype: 'path_delivery'   //placeholder billinc codes
            // },
            performedby: {
                defaultValue: LABKEY.Security.currentUser.displayName,
                hidden: false,
                header: 'Completed by'
            }
        },
        'study.tissue_samples': {

            performedby: {
                defaultValue: LABKEY.Security.currentUser.displayName,
                hidden: false,
                header: 'Completed by'
            },
            date: {
                xtype: 'xdatetime',
                extFormat: 'Y-m-d H:i',
                defaultValue: (new Date()).format('Y-m-d 8:00')
            }
        }
    }
});