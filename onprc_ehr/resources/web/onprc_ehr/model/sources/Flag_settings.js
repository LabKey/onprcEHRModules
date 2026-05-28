/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Flag_Settings', {
    allQueries: {

    },
    byQuery: {
        'study.flags': {
            date: {
                xtype: 'xdatetime',
                extFormat: LABKEY.extDefaultDateTimeFormat,
                editorConfig: {
                    dateFormat: LABKEY.extDefaultDateFormat,
                    timeFormat: 'H:i'
                }

            },
            enddate: {
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