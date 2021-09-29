
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('ARTCore_Services', {
            allQueries: {
            },

            byQuery: {
                'study.encounters': {
                    chargetype: {
                        defaultValue: 'ART',
                        hidden: true
                    },
                    date: {
                        xtype: 'xdatetime',
                        extFormat: 'Y-m-d H:i',
                        defaultValue: (new Date()).format('Y-m-d 8:0')
                    },
                    type: {
                        defaultValue: 'Procedure',
                        hidden: true
                    },
                    procedureid: {
                        lookup: {
                            filterArray: [
                                LABKEY.Filter.create('category', 'ART', LABKEY.Filter.Types.EQUAL),
                                LABKEY.Filter.create('active', true, LABKEY.Filter.Types.EQUAL)
                            ]
                        }
                    }
                }


            }
        }
);