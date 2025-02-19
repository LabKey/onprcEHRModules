
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */


EHR.model.DataModelManager.registerMetadata('CMU_Services', {
    allQueries: {

    },
    byQuery: {
        'study.treatment_order': {
            chargetype: {
                defaultValue: 'DCM: Clinical Services',
                hidden: false
            },
            date: {
                defaultValue: Ext4.Date.add(new Date(), Ext4.Date.DAY, 1)
            },
            Billable: {
                defaultValue: 'Yes',
                hidden: true
            },
            code: {
                header: 'Treatment',
                editorConfig: {
                    defaultSubset: 'All'
                }
            },
            category: {
                defaultValue: 'Clinical on behalf of Research',
                hidden: true
            },
            remark: {
                header: 'Remark',
                hidden: false
            }
        },

        'ehr.requests': {
            remark: {
                label: 'Lab Phone # ',
                width: 300,
                height: 20,
                hidden: false
            }

        }
    }
});