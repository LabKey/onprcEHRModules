
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('EmployeeRequiredCategory', {
    allQueries: {

    },
    byQuery: {
        'ehr_compliancedb.employeeperUnit': {
            employeeid: {
                hidden: false,
                anyMatch: true,
                allowBlank: false,
                columnConfig: {
                    width: 350,
                    header: 'Employee ID'
                },
                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_compliancedb',
                    queryName: 'employeelist',
                    keyColumn: 'employeeid',
                    displayColumn: 'employeeid',
                    sort: 'employeeid'

                }

            },

            unit: {
                hidden: false,
                allowBlank: false,
                hasOwnTpl: true,
                includeNullRecord: false,
                columnConfig: {
                    width: 300,
                    header: 'Unit'
                },
                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_compliancedb',
                    queryName: 'unit_names',
                    keyColumn: 'unit',
                    displayColumn: 'unit',
                    columns: 'unit',
                    sort: 'unit'

                }


            }

        }}
})