
/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
                        LABKEY.Filter.create('category', 'Surgery', LABKEY.Filter.Types.NEQ),
                        LABKEY.Filter.create('category', 'Pathology', LABKEY.Filter.Types.NEQ),
                        LABKEY.Filter.create('active', true, LABKEY.Filter.Types.EQUAL)
                    ]
        }}},
        'study.blood': {
            chargetype: {
                defaultValue: 'DCM: ASB Services',
                hidden: true
            },
            performedby: {
                //defaultValue: LABKEY.Security.currentUser.displayName,
                hidden: false,
                header: 'Completed by'
            },
            date: {
                xtype: 'xdatetime',
                extFormat: 'Y-m-d H:i',
                defaultValue: (new Date()).format('Y-m-d 8:0')
            }
        },
        'study.drug': {
            chargetype: {
                defaultValue: 'DCM: ASB Services',
                hidden: true
            },
            date: {
                xtype: 'xdatetime',
                extFormat: 'Y-m-d H:i',
                defaultValue: (new Date()).format('Y-m-d 8:0')
            },
            Billable: {
                defaultValue: 'Yes',
                hidden: false
            },
            category: {
                defaultValue: 'Research',
                hidden: true
            },
            remark: {
                header: 'Special Instructions',
                hidden: false
            },
            reason: {
                defaultValue: 'Research',
                hidden: false
            },
            lot: {
                hidden: true
            },
            code: {
                editorConfig: {
                    defaultSubset: 'Research'
                },
                header: 'Agent Administered'
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
        // Modified: 7-27-2017  R.Blasa  not needed for this version
        //'study.treatment_order': {
        //    chargetype: {
        //        defaultValue: 'DCM: ASB Services',
        //        hidden: true
        //    },
        //    date: {
        //        defaultValue: new Date()
        //    },
        //    Billable: {
        //        defaultValue: 'Yes',
        //        hidden: true
        //    },
        //    code: {
        //        header: 'Agent',
        //        editorConfig: {
        //            defaultSubset: 'Research'
        //        }
        //    },
        //    category: {
        //        defaultValue: 'Research',
        //        hidden: true
        //    },
        //    remark: {
        //        header: 'Special Instructions',
        //        hidden: false
        //    }
        //}
    }
});