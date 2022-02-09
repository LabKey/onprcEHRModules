
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('EmployeeCategoryRecords', {
    allQueries: {

    },
    byQuery: {
        'ehr_compliancedb.requirementspercategory': {
            requirementname: {
                hidden: false,
                allowBlank: false,
                columnConfig: {
                    width: 350,
                    header: 'Requirement Name'
                },
                editorConfig: {
                    caseSensitive: false,
                    anyMatch: true
                },

                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_compliancedb',
                    queryName: 'Requirements',
                    keyColumn: 'requirementname',
                    displayColumn: 'requirementname',
                    filterArray: [
                        LABKEY.Filter.create('datedisabled', null, LABKEY.Filter.Types.ISBLANK)
                    ],
                    columns: 'requirementname',
                    sort: 'requirementname'

                }

            },
            category: {
                hidden: false,
                allowBlank: true,
                columnConfig: {
                    width: 150,
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
                allowBlank: true,
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


            },
             rowid:{hidden: true},
            trackingflag: {
                hidden: false,
                allowBlank: false,
                columnConfig: {
                    width: 100,
                    header: 'Essential'
                },
                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/EHR',
                    schema: 'ehr_compliancedb',
                    queryName: 'essentialflag',
                    keyColumn: 'value',
                    displayColumn: 'value',
                    columns: 'value',
                    sort: 'value'


                }
            },


        }}
});
