/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created: 10-10-2017  R.Blasa

EHR.model.DataModelManager.registerMetadata('ClinicalRounds_ONPRC', {
    allQueries: {

    },
    byQuery: {
        'study.clinremarks': {
            Id: {
                editable: false,
                columnConfig: {
                    editable: false
                }
            },
            category: {
                defaultValue: 'Clinical',
                hidden: true
            },
            hx: {
                hidden: false
            },
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
            CEG_Plan: {

                height: 22
            },
            remark: {
                hidden: false
            }
        },
        'study.blood': {
            reason: {
                defaultValue: 'Clinical'
            },
            instructions: {
                hidden: true
            }
        },
        'study.encounters': {
            instructions: {
                hidden: true
            }
        },
        'study.clinical_observations': {
            Id: {
                editable: false,
                columnConfig: {
                    editable: false
                }
            }
        }
    }
});