/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('ASB_Services', {
    allQueries: {

    },
    byQuery: {
        'study.encounters': {
            chargetype: {
                defaultValue: 'DCM: ASB Services',
                hidden: true
            }
        },
        'study.blood': {
            chargetype: {
                defaultValue: 'DCM: ASB Services',
                hidden: true
            }
        }
    }
});