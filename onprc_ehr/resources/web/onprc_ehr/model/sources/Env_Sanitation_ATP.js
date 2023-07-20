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
                    width: 80
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
                    width: 160
                }
            },
            test_results: {
                // xtype: 'onprc-env_testresults',
                header: 'Lab/Group',
                columnConfig: {
                    width: 100
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
            biological_reader: {
                header: 'Surface Tested',
                columnConfig: {
                    width: 150
                }
            },
            biological_cycle: {
                hidden: true
            },
            biological_BI: {
                hidden: true
            },
            testing_equipment: {
                hidden: true
            },
            surface_tested: {
                hidden: true
            },
            water_source: {
                header: 'Retest',
                hidden: false,
                columnConfig: {
                    width: 100
                }
            },
            test_type: {
                hidden: true
            },
            retest: {
                hidden: true
            },
            pass_fail: {
                // xtype: 'onprc-env_passfail',
                header: 'Initial',
                columnConfig: {
                    width: 100
                }
            },
            colony_count: {
                hidden: true
            },
            remarks: {
                header: 'Comments',
                columnConfig: {
                    width: 170
                }
            }
        }
    }
});