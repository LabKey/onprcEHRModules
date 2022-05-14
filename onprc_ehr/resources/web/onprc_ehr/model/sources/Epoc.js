/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Epoca', {
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
        },
        'study.EPOC': {
            resultOORIndicator: {
                hidden: true
            },
            result: {
                allowBlank: false,
                compositeField: 'Result'
            },
            units: {
                compositeField: 'Result'
            },
            testid: {
                lookup: {
                    columns: '*'
                }
            },
            qualresult: {
                hidden: true
            }
        },
    }
});