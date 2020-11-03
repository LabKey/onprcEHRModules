/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created 12-26-2017  R.Blasa
EHR.model.DataModelManager.registerMetadata('ParentageProperty', {
    allQueries: {

    },
    byQuery: {

        'study.parentage': {

            date: {
                xtype: 'datefield',
                extFormat: LABKEY.extDefaultDateFormat,
                columnConfig: {
                    width: 100
                }
            }
        }

    }
});