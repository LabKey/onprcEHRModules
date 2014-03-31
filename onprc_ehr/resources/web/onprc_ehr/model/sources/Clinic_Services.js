/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Clinic_Services', {
    allQueries: {

    },
    byQuery: {
        'study.encounters': {
            chargetype: {
                defaultValue: 'DCM: Clinic Services',
                hidden: true
            }
        },
        'study.blood': {
            chargetype: {
                defaultValue: 'DCM: Clinic Services',
                hidden: true
            }
        }
    }
});