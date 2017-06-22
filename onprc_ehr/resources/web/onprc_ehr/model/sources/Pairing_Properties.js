/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created 6-7-2016  R.Blasa
EHR.model.DataModelManager.registerMetadata('Pairing_Properties', {
    allQueries: {

    },
    byQuery: {

        'study.pairings': {

            outcome: {
                allowBlank: false,

                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }

            }  ,

            eventType: {
                allowBlank: false,

                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }


            },

            goal: {
                allowBlank: false,

                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('dated_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }


            },
            separationreason: {
                allowBlank: false,

                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }


            },
            observation: {
                columnConfig: {
                    width: 200
                },
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('date_disabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                }

            }
        }

    }
});