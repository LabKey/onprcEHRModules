/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Environmental_ATP', {
    allQueries: {

    },
    byQuery: {
        'onprc_ehr.Environmental_Assessment': {
            date: {
                header: 'Date',
                columnConfig: {
                    width: 100
                }
            },
            service_requested: {
                xtype: 'onprc-env_servicetype',
                defaultValue: 'Sanitation: ATP',
                columnConfig: {
                    width: 200
                }
            },

            charge_unit: {
                xtype: 'onprc-env_chargeunit',
                columnConfig: {
                    width: 100
                }
            },
            testing_location: {
                xtype: 'onprc-env_testLocation',
                header: 'Area',
                columnConfig: {
                    width: 140
                }
            },
            test_results: {
                xtype: 'onprc-env_labgroup',
                header: 'Lab/Group',
                columnConfig: {
                    width: 140
                }
            },

            performedby: {
                hidden: true
            },
            action: {
                header: 'Location Tested',
                hidden: false,
                columnConfig: {
                    width: 120
                }
            },
            biological_cycle: {
                hidden: true
            },
            biological_BI: {
                hidden: true
            },
            surface_tested: {
                xtype: 'onprc-env_surfacetest',
                hidden: false,
                columnConfig: {
                    width: 180
                }
            },
            water_source: {
                hidden: true
             },
            test_type: {
                hidden: true
            },
            retest: {
                header: 'Retest',
                hidden: false
            },
            pass_fail: {
                header: 'Initial',
                columnConfig: {
                    width: 100
                }
            },
            colony_count: {
                hidden: true
            },
            test_method: {
                hidden: true
            },
            remarks: {
                xtype: 'textfield',
                header: 'Comments',
                columnConfig: {
                    width: 150
                }
            }
        }
    }
});