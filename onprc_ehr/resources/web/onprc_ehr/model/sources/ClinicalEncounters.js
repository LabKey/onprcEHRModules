/*
 * Copyright (c) 2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('ClinicalEncounters', {
    allQueries: {

    },
    byQuery: {
        'study.encounters' : {
            date: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat
            }
        }
    }
});
