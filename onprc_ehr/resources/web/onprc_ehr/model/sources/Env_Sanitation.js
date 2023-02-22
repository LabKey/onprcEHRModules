/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Environmental', {
    allQueries: {

    },
    byQuery: {
        'onprc_ehr.Environmental_Assessment': {
            service_requested: {
                xtype: 'onprc-env_servicetype',
                columnConfig: {
                    width: 200
                }
            },
            testing_location: {
                xtype: 'onprc-env_testLocation',
                columnConfig: {
                    width: 200
                }
            },
            performedby: {
                header: 'Performed by',
                defaultValue: LABKEY.Security.currentUser.displayName
            },
            action: {
                hidden: true
            },
            biological_reader: {
                hidden: true
            },
            biological_cycle: {
                hidden: true
            },
            collectedby: {
                hidden: true
            },
            pass_fail: {
                xtype: 'onprc-env_passfail',
                columnConfig: {
                    width: 400
                }
            },
            colony_count: {
                hidden: true
            }
        }
    }
});