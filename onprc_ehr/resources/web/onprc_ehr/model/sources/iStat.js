/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('iStat', {
    allQueries: {

    },
    byQuery: {
        'study.clinpathRuns': {
            method: {
                hidden: true
            },
            category: {
                hidden: true
            },
            collectionMethod: {
                hidden: true
            },
            chargetype: {
                hidden: true
            },
            project: {
                allowBlank: true,
                hidden: true
            }
        }
    }
});