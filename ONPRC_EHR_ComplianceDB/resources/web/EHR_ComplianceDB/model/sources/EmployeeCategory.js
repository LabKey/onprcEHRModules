
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('EmployeeRequiredCategory', {
    allQueries: {

    },
    byQuery: {
        'ehr_compliancedb.requirementspercategory': {
            requirementname: {
                hidden: false,
                anyMatch: true,
                allowBlank: false,
                columnConfig: {
                    width: 350,
                    header: 'Requirement Name'
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
                xtype: 'labkey-combo',
                lookup: {
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_compliancedb',
                    queryName: 'employeecategory',
                    keyColumn: 'categoryname',
                    displayColumn: 'categoryname',
                    columns: 'categoryname',
                    sort: 'categoryname'
                },

                columnConfig: {
                    width: 300
                }
            },
            rowid: {hidden: true},
            trackingflag: {
                hidden: false,
                allowBlank: false,
                columnConfig: {
                    width: 100,
                    header: 'EssentialT'
                },
                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/EHR',
                    schema: 'sla',
                    queryName: 'Reference_Data',
                    keyColumn: 'value',
                    displayColumn: 'value',
                    columns: 'value',
                    sort: 'value',
                    filterArray: [
                        LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                        LABKEY.Filter.create('ColumnName', 'NecropsyDist', LABKEY.Filter.Types.EQUAL)],
                    autoLoad: true

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