/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('MedSignOff', {
    allQueries: {

    },
    byQuery: {
        'study.Drug': {
            Id: {
                userEditable: false,
                header: 'Animal ID'
            },
            date: {
                userEditable: false,
                header: 'Monkey Date'
            }

        },
    }
});