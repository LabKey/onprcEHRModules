/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 2-24-2021
EHR.model.DataModelManager.registerMetadata('Biopsy_Notes', {

    byQuery: {

        'study.histology': {
            codesRaw: {
                header: 'Snomed Codes'
            }
        },

        'study.encounters': {
            project: {
                xtype: 'onprc_ehr-projectentryfield'
            },
            remark: {
                defaultValue: ' CLINICAL HISTORY: \n\n\n GROSS DESCRIPTION: \n\n\n COMMENTS: \n\n\n',
                hidden: false
              }
        },

        'study.pathologyDiagnoses': {
            codesRaw: {
                header: 'Snomed Codes'
            }
        }
    }
});