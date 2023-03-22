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
                    width: 140
                }
            },
            charge_unit: {
                xtype: 'onprc-env_chargeunit',
                columnConfig: {
                    width: 100
                }
            },
            test_results: {
                xtype: 'onprc-env_testresults',
                columnConfig: {
                    width: 100
                }
            },
            remarks: {
                header: 'Comments',
                  columnConfig: {
                    width: 150
                }
            },
            performedby: {
                header: 'Collected by',
                defaultValue: LABKEY.Security.currentUser.displayName
            },
            action: {
                header: 'Action',
                hidden: false,
                columnConfig: {
                    width: 80
                }
            },
            biological_reader: {
                hidden: true
            },
            biological_cycle: {
                header: 'Cycle',
                hidden: false,
                columnConfig: {
                    width: 70
                }
            },
            biological_BI: {
                header: 'Bl#',
                hidden: false,
                columnConfig: {
                    width: 90
                }
            },
            testing_equipment: {
                hidden: true
            },
            surface_tested: {
                hidden: true
            },
            water_source: {
                header: 'H2O Source',
                hidden: false,
                columnConfig: {
                    width: 90
                }
            },
            test_type: {
                header: 'Test Type',
                hidden: false,
                columnConfig: {
                    width: 80
                }
            },
            retest: {
                hidden: true
            },
            pass_fail: {
                xtype: 'onprc-env_passfail',
                columnConfig: {
                    width: 100
                }
            },
            colony_count: {
                hidden: false,
                columnConfig: {
                    width: 90
                }
            }
        }
    }
});