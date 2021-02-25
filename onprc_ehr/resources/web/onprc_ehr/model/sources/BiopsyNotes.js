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
                xtype: 'ehr-projectfield',
                editorConfig: {
                    showInactive: false
                }
            }
        }


    }
});