/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Necropsy_Notes', {

    byQuery: {

        'ehr.encounter_summaries': {
            Id: {
                hidden: true
            },
            date: {
                hidden: true
            },
            category: {
                defaultValue: 'Pathology Notes',
                hidden: true
            },
            RemarkHistory: {

                hidden: true
            },
            remark: {
                height: 300,
                editorConfig: {
                    fieldLabel: 'Notes',
                    width: 1000
                }
            }
        },
        'onprc_ehr.encounter_summaries_remarks': {
            Id: {
                hidden: true
            },
            date: {
                hidden: true
            },
            category: {
                defaultValue: 'Pathology Notes',
                hidden: true
            },
            createdBy: {

                hidden: true
            },
            modifiedBy: {

                hidden: true
            },
            remark: {
                height: 300,
                editorConfig: {
                    fieldLabel: 'Notes - History',
                    width: 1000
                }
            }
        }

    }
});