/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * This is the default metadata applied to records in SLA forms
 */

//Modified 11-5-2016  R. Blasa
EHR.model.DataModelManager.registerMetadata('NHPTraining', {
    allQueries: {

    },
    byQuery: {
        'onprc_ehr.NHP_Training': {
            training_Start_Date: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat,
                columnConfig: {
                    width: 150
                }
            },

            training_End_Date: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat,
                columnConfig: {
                    width: 150
                }
            },

            //Added: 5-22-2018  R.Blasa
            created: {
                hidden: true,
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat
            },
        //Added: 5-22-2018  R.Blasa
            modified: {
                hidden: true,
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat
            },

            training_type: {
                allowBlank: false,
                xtype: 'onprc_TrainingType' ,
                columnConfig: {
                    width: 200
                }
            },

                //Added: 11-22-2016 R.Blasa
            training_results: {
                allowBlank: false,
                xtype: 'onprc_TrainingResults' ,
                columnConfig: {
                    width: 200
                }
            },


            performedby: {
                defaultValue: LABKEY.Security.currentUser.displayName ,
                hidden: false

            },
            reason: {
                allowBlank: false,
                xtype: 'onprc_TrainingReason',
                columnConfig: {
                    width: 200
                }
            }


        }
    }
});