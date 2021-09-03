
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('EmployeeListRecords', {
    allQueries: {

    },
    byQuery: {
        'ehr_compliancedb.employees': {
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
                    schema: 'ehr_complianceDB',
                    queryName: 'unit_names',
                    keyColumn: 'unit',
                    displayColumn: 'unit',
                    columns: 'unit',
                    sort: 'unit'

                }

            },
            category: {
                xtype: 'labkey-combo',
                lookup: {
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_complianceDB',
                    queryName: 'employeecategory',
                    keyColumn: 'categoryname',
                    displayColumn: 'categoryname',
                    columns: 'categoryname',
                    sort: 'categoryname'
                },
                columnConfig: {
                    width: 200
                }
            },
            title: { columnConfig: {
                    width: 200
                }},

            enddate: { columnConfig: {
                    width: 100
                }},
            emergencycontact: {hidden: true},
            emergencycontactdaytimephone: {hidden: true},
            emergencycontactnighttimephone: {hidden: true},
            homephone: {hidden: true},
            officephone: {hidden: true},
            cellphone: {hidden: true},
            email2: {hidden: true},
            barrier: {hidden: true},
            animals: {hidden: true},
            contactsSla: {hidden: true},
            tissue: {hidden: true},
            Notes: {hidden: false},
            QCState: {hidden: true},
            isActive: {hidden: false}

        }}
});
