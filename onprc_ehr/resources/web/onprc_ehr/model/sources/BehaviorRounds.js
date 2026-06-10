/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

EHR.model.DataModelManager.registerMetadata('BehaviorRounds', {
    allQueries: {
        performedby: {
            lookup: {
                schemaName: 'core',
                queryName: 'users',
                keyColumn: 'DisplayName',
                displayColumn: 'DisplayName',
                columns: 'UserId,DisplayName,FirstName,LastName',
                sort: 'Type,DisplayName'
            },
            editorConfig: {
                anyMatch: true,
                listConfig: {
                    innerTpl: '{[LABKEY.Utils.encodeHtml(values.DisplayName + (values.LastName ? " (" + values.LastName + (values.FirstName ? ", " + values.FirstName : "") + ")" : ""))]}',
                    getInnerTpl: function(){
                        return this.innerTpl;
                    }
                }
            }
        }
    },
    byQuery: {
        'study.clinremarks': {
            s: {
                hidden: true
            },
            o: {
                hidden: true
            },
            a: {
                hidden: true
            },
            p: {
                hidden: true
            },
            remark: {
                columnConfg: {
                    width: 360
                },
                height: 60
            }
        },
        'study.clinical_observations': {
            Id: {
                editable: false,
                columnConfig: {
                    editable: false
                }
            },
            caseid: {
                hidden: false,
                columnConfig: {
                    width: 10,
                    editable: false
                }
            }
        }
    }
});