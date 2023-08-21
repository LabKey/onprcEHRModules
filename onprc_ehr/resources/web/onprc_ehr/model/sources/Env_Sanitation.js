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
            date: {
                header: 'Date',
                columnConfig: {
                    width: 100
                }
            },
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
            charge_unit: {
                xtype: 'onprc-env_chargeunit',
                defaultValue: 'Clinpath',
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
            test_method: {
                xtype: 'onprc-env_method',
                header: 'Method',
                columnConfig: {
                    width: 150
                }
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

            surface_tested: {
                hidden: true
            },
            water_source: {
                xtype: 'onprc-env_watersource',
                defaultValue: 'Lixit',
                header: 'H2O Source',
                hidden: false,
                columnConfig: {
                    width:150
                }
            },
            test_type: {
                xtype: 'onprc-env_passfail',
                header: 'Test Type',
                defaultValue: 'Initial',
                hidden: false,
                columnConfig: {
                    width: 80
                }
            },
            retest: {
                hidden: false,
                header: 'Results Read by',
                columnConfig: {
                    width: 90
                }
            },

            pass_fail: {
                xtype: 'onprc-env_passfail',
                columnConfig: {
                    width: 100
                }
            },
            colony_count: {
                hidden: false,
                header: 'Colony Count',
                columnConfig: {
                    width: 90
                }
            }
        }
    }
});