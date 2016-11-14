/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created 2-5-2016 Blasa
EHR.model.DataModelManager.registerMetadata('LabworkTestPanel', {
    allQueries: {

    },
    byQuery: {
        'study.microbiology': {
             servicerequest: {
                 columnConfig: {
                     width: 200
                 },
                 allowBlank: false

           }
        },
        'study.hematologyResults': {           //Added 3-14-2016 Blasa
            date: {
                xtype: 'xdatetime',
                extFormat: LABKEY.extDefaultDateTimeFormat,
                editorConfig: {
                    dateFormat: LABKEY.extDefaultDateFormat,
                    timeFormat: 'H:i'
                }
            }
        } ,
        'study.chemistryResults': {           //Added 3-14-2016 Blasa
            date: {
                xtype: 'xdatetime' ,
                extFormat: LABKEY.extDefaultDateTimeFormat,
                editorConfig: {
                    dateFormat: LABKEY.extDefaultDateFormat,
                    timeFormat: 'H:i'
                }
             }
        } ,
        'study.urinalysisResults': {        //Added 3-14-2016 Blasa
            date: {
                xtype: 'xdatetime',
                extFormat: LABKEY.extDefaultDateTimeFormat,
                editorConfig: {
                    dateFormat: LABKEY.extDefaultDateFormat,
                    timeFormat: 'H:i'
                }
            }
        } ,
        'study.antibioticSensitivity': {      //Added 3-14-2016 Blasa
            date: {
                xtype: 'xdatetime',
                extFormat: LABKEY.extDefaultDateTimeFormat,
                editorConfig: {
                    dateFormat: LABKEY.extDefaultDateFormat,
                    timeFormat: 'H:i'
                }
            }
        } ,
        'study.parasitologyResults': {      //Added 3-14-2016 Blasa
            date: {
                xtype: 'xdatetime',
                extFormat: LABKEY.extDefaultDateTimeFormat,
                editorConfig: {
                    dateFormat: LABKEY.extDefaultDateFormat,
                    timeFormat: 'H:i'
                }
            }
        }

      }
});