/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('SurgicalRounds', {
    allQueries: {
        Id: {
            editable: false,
            columnConfig: {
                editable: false
            }
        }
    },
    byQuery: {
        'study.clinremarks': {
            category: {
                defaultValue: 'Surgery',
                hidden: true
            },
            hx: {
                hidden: true
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
                hidden: true
            },
            P2: {
                header: 'S2',
                hidden: false,
                height: 75
            }

        },
        'study.blood': {
            reason: {
                defaultValue: 'Clinical'
            }
        }
    }
});