/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Colony_Services', {
    allQueries: {

    },
    byQuery: {
        'study.encounters': {
            chargetype: {
                defaultValue: 'DCM: Colony Services',
                hidden: true
            }
        },
        'study.blood': {
            chargetype: {
                defaultValue: 'DCM: Colony Services',
                hidden: true
            }
        },
        'study.drug': {
            chargetype: {
                defaultValue: 'DCM: Colony Services',
                hidden: true
            },
            code: {
                editorConfig: {
                    defaultSubset: 'Drugs and Procedures'
                }
            }
        }
    }
});