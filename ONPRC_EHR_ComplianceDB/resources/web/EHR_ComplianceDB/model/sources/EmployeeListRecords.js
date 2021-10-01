
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('EmployeeListRecords', {
    allQueries: {

    },
    byQuery: {
        'ehr_compliancedb.EmployeePerEssential': {

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


        }}
});
