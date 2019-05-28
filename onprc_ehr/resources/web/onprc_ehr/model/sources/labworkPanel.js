/*
 * Copyright (c) 2014-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created 2-5-2016 Blasa
EHR.model.DataModelManager.registerMetadata('LabworkPanel', {
    allQueries: {

    },
    byQuery: {
        'study.clinpathRuns': {

            performedby: {
                defaultValue: LABKEY.Security.currentUser.displayName ,
                hidden: false
            }

        }
    }
});