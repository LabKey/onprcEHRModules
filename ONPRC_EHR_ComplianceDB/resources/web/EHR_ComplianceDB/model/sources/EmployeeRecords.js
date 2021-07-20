
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('EmployeeRecords', {
    allQueries: {

    },
    byQuery: {
        'ehr_compliancedb.completiondates': {
            employeeid: {
                hidden: false,
                allowBlank: false,
                columnConfig: {
                    width: 250,
                    header: 'Employees'
                },
                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/Admin/Compliance',
                    schema: 'ehr_complianceDB',
                    queryName: 'employees',
                    keyColumn: 'employeeid',
                    displayColumn: 'employeeid',
                    filterArray: [
                        LABKEY.Filter.create('isActive', true, LABKEY.Filter.Types.EQUAL)],
                    columns: 'employeeid,firstName,lastName',
                    sort: 'lastName'

                },
                editorConfig: {
                    anyMatch: true,
                    listConfig: {
                        innerTpl: '{[values.employeeid + (values.employeeid ? " (" + values.lastName + (values.firstName ? ", " + values.firstName : "") + ")" : "")]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                }
            },
            date: {
                xtype: 'xdatetime',
                header: 'Completion Dates',
                extFormat: 'Y-m-d',
                defaultValue: (new Date()).format('Y-m-d'),
                header:'Completion Date'
            },

            requirementname: {
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('datedisabled', null, LABKEY.Filter.Types.ISBLANK)
                    ]
                },
                header: 'Requirement Name',
                columnConfig: {
                    width: 250
                }
            },


            trainer: {
                hidden: false,
                allowBlank: false,
                columnConfig: {
                    width: 150
                },
                lookup: {
                    xtype: 'labkey-combo',
                    containerPath: '/ONPRC/Admin/Compliance',
                    queryName: 'trainers',
                    keyColumn: 'employeeid',
                    displayColumn: 'employeeid',
                    // filterArray: [
                    //     LABKEY.Filter.create('isActive', true, LABKEY.Filter.Types.EQUAL)],
                    columns: 'employeeid,firstName,lastName',
                    sort: 'lastName'

                }

            },
            rowid: {
                hidden: true
            },
            result: {
                xtype: 'textfield',
                header: 'Results',
                width: 200,
                height:30
            },
            comment: {
                xtype: 'textfield',
                header: 'Comments',
                width: 300,
                height:30
            },
            filename: {
                xtype: 'textfield',
                header: 'File Name',
                width: 300,
                height:30
            }
        }}
});