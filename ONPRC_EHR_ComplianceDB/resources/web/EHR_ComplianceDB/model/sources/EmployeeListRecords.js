
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
                  category: {
                        xtype: 'checkcombo',
                        hasOwnTpl: true,
                        includeNullRecord: false,
                        lookup: {
                            containerPath: '/ONPRC/Admin/Compliance',
                            schema: 'ehr_complianceDB',
                            queryName: 'employeecategory',
                            keyColumn: 'categoryname',
                            displayColumn: 'categoryname',
                            columns: 'categoryname',
                            sort: 'categoryname'
                        },
                        editorConfig: {
                            tpl: null,
                            multiSelect: true,
                            separator: ';'
                        },
                        columnConfig: {
                            width: 200
                        }
                    },
                    title: { columnConfig: {
                            width: 200
                        }},
                    unit: { columnConfig: {
                     width: 150
                 }},
                    majorudds: {hidden: true},
                    email2: {hidden: true}


        }}
});
