
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
                anyMatch: true,
                allowBlank: true,
                columnConfig: {
                    width: 350,
                    header: 'Employee ID'
                },
                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_compliancedb',
                    queryName: 'Employeelist',
                    keyColumn: 'employeeid',
                    // displayColumn: 'employeeid',
                    sort: 'employeeid',
                    columns: 'employeeid,lastName,FirstName'

                },
                editorConfig: {
                    anyMatch: true,
                    listConfig: {
                        innerTpl: '{[LABKEY.Utils.encodeHtml(values.employeeid + (values.LastName ? " (" + values.LastName + (values.FirstName ? ", " + values.FirstName : "") + ")" : ""))]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                }
            },
            category: {
                hidden: false,
                anyMatch: true,
                allowBlank: true,
                hasOwnTpl: true,
                columnConfig: {
                    width: 300,
                    header: 'Category'
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
                anyMatch: true,
                allowBlank: true,
                hasOwnTpl: true,
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