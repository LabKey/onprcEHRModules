/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('ClinicalProcedures', {
    allQueries: {
        performedby: {
            allowBlank: true
        }
    },
    byQuery: {
        'study.encounters': {
            instructions: {
                hidden: true
            },
            chargetype: {
                defaultValue: 'No Charge',
                allowBlank: false
            },
            performedby: {
                defaultValue: LABKEY.Security.currentUser.displayName
            },
            type: {
                defaultValue: 'Procedure',
                hidden: true
            },
            title: {
                hidden: true
            },
            caseno: {
                hidden: true
            },
            remark: {
                columnConfig: {
                    width: 400
                }
            },
            procedureid: {
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('category', 'Surgery', LABKEY.Filter.Types.NEQ),
                        LABKEY.Filter.create('category', 'Pathology', LABKEY.Filter.Types.NEQ),
                        LABKEY.Filter.create('active', true, LABKEY.Filter.Types.EQUAL)
                    ]
                }
            }
        },



    }
});