/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created 5-26-2016  R.Blasa
EHR.model.DataModelManager.registerMetadata('ProjectAnimalConditions', {
    allQueries: {

    },
    byQuery: {

        'study.Assignment': {

            assignCondition: {
                allowBlank: false,
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('datedisabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }

            } ,
            projectedReleaseCondition: {
                allowBlank: false,
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('datedisabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }

            },

                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('datedisabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }

            }

    }
    });