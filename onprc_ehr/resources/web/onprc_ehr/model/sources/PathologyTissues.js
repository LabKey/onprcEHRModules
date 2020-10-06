/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 5-5-2017   R.Blasa
EHR.model.DataModelManager.registerMetadata('PathTissues', {
    allQueries: {
    },
    byQuery: {
        'study.encounters': {
            type: {
                defaultValue: 'Tissues',
                hidden: true
            },
            enddate: {
                hidden: true
            },
            project: {
                header: 'Center Project'
            },


            chargetype: {
                hidden: true
            },
            procedureid: {
                defaultValue: 1082,
                hidden: true
            },

            caseno: {
                hidden: true
            },
            remark: {
                hidden: true
            }
        }
    }
});