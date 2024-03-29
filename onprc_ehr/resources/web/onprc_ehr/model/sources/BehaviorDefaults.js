/*
 * Copyright (c) 2014-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * Added by Kollil on 12/18/23. Please refer to tke # 10285 for details
 */
EHR.model.DataModelManager.registerMetadata('BehaviorDefaults', {
    allQueries: {

    },
    byQuery: {
        'study.clinremarks': {
            category: {
                defaultValue: 'Behavior',
                hidden: true
            },
            hx: {
                hidden: true
            },
            s: {
                hidden: false
            },
            o: {
                hidden: false
            },
            a: {
                hidden: false
            },
            p: {
                hidden: false
            },
            p2: {
                hidden: true
            },
            remark: {
                columnConfg: {
                    width: 350
                }
            }
        },
        'study.drug': {
            category: {
                defaultValue: 'Behavior'
            },
            code: {
                editorConfig: {
                    xtype: 'ehr-snomedcombo',
                    defaultSubset: 'Behavior'
                }
            },
            concentration: {
                hidden: true
            },
            conc_units: {
                hidden: true
            },
            dosage: {
                hidden: true
            },
            dosage_units: {
                hidden: true
            },
            volume: {
                hidden: true
            },
            vol_units: {
                hidden: true
            },
            amount: {
                //hidden: true,
                defaultValue: 1
            },
            amount_units: { //Changed by Kolli: 12/18/2023.
                hidden: false,
                defaultValue:'units'
            },
            lot: {
                hidden: true
            },
            outcome: {
                hidden: true
            },
            route: {
                hidden: true,
                allowBlank: true
            },
            reason: {
                hidden: true
            },
            qualifier: {
                hidden: true
            },
            enddate: {
                hidden: true
            },
            project: {
                getInitialValue: function(v, rec){
                    //return a default value only if this field is visible
                    var shouldReturn = false;
                    if (rec){
                        var meta = rec.fields.get('project');
                        if (meta){
                            shouldReturn = meta.hidden == false
                        }
                    }
                    return v ? v : shouldReturn ? EHR.DataEntryUtils.getDefaultClinicalProject() : null;
                }
            },
            chargetype: {
                defaultValue: 'No Charge'
            }
        },
        'study.clinical_observations': {
            area: {
                hidden: true
            },
            category: {
                lookup: {
                    filterArray: [LABKEY.Filter.create('category', 'Behavior')]
                }
            }
        }
    }
});