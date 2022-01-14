
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('EmployeeRequiredUnit', {
    allQueries: {

    },
    byQuery: {
        'ehr_compliancedb.employeeperUnit': {
            employeeid: {
                hidden: false,
                allowBlank: false,
                columnConfig: {
                    width: 350,
                    header: 'Employee ID'
                },
                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_compliancedb',
                    queryName: 'Employees',
                    keyColumn: 'employeeid',
                    sort: 'employeeid',
                    columns: 'employeeid,lastName,firstName'

                },
                editorConfig: {
                    anyMatch: true,
                    listConfig: {
                        innerTpl: '{[LABKEY.Utils.encodeHtml(values.employeeid + (values.lastName ? " (" + values.lastName + (values.firstName ? ", " + values.firstName : "") + ")" : ""))]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                }
            },
            category: {
                hidden: false,
                allowBlank: false,
                hasOwnTpl: true,
                columnConfig: {
                    width: 300,
                    header: 'Category'
                },

                editorConfig: {
                    caseSensitive: false,
                    anyMatch: true
                },

                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_compliancedb',
                    queryName: 'employeecategory',
                    keyColumn: 'categoryname',
                    displayColumn: 'categoryname',
                    columns: 'categoryname',
                    sort: 'categoryname'

                }


            },

            unit: {
                hidden: false,
                allowBlank: false,
                hasOwnTpl: true,
                columnConfig: {
                    width: 300,
                    header: 'Unit'
                },
                editorConfig: {
                    caseSensitive: false,
                    anyMatch: true
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