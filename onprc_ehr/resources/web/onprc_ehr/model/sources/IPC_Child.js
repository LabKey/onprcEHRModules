/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('IPC_Child', {
    allQueries: {
        Id: {
            editable: false,
            columnConfig: {
                editable: false
            }
        },
        date: {
            inheritDateFromParent: true
        }
    }
});