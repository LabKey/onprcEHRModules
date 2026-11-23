/*
 * Copyright (c) 2025 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('MedSignOff', {
    allQueries: {

    },
    byQuery: {
        'study.drug': {
            Id: {
                dataIndex: 'Id',
                userEditable: false,
                editable: false

            },
            date: {
                dataIndex: 'date',
                userEditable: false,
                editable: false

            }

        },
    }
});