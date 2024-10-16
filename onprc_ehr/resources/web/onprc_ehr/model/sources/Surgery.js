/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

// Created: 4-20-2021  R. Blasa
EHR.model.DataModelManager.registerMetadata('onprc_Surgery', {
    allQueries: {
        performedby: {
            allowBlank: true
        }
    },
    byQuery: {
        'onprc_billing.miscCharges': {
            chargeId: {
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('active', true, LABKEY.Filter.Types.EQUAL),
                        LABKEY.Filter.create('category', 'Lease Fee', LABKEY.Filter.Types.NEQ),
                        LABKEY.Filter.create('category', 'Animal Per Diem', LABKEY.Filter.Types.NEQ),
                        LABKEY.Filter.create('category', 'Small Animal Per Diem', LABKEY.Filter.Types.NEQ),
                        LABKEY.Filter.create('category', 'Timed Mated Breeders', LABKEY.Filter.Types.NEQ)
                    ]
                }
            },
            chargetype: {
                //NOTE: this will be inherited from the encounters record, so we dont want a default
                //defaultValue: 'DCM: Surgery Services',
                allowBlank: false
            }
        },
        'study.treatment_order': {
            category: {
                shownInGrid: true,
                defaultValue: 'Surgical',
                allowBlank: false
            }

        },
        'study.drug': {
            enddate: {
                hidden: false
            },
            category: {
                shownInGrid: true,
                hidden: false,
                defaultValue: 'Surgical'
            },
            reason: {
                defaultValue: 'Procedure'
            },
            chargetype: {
                //NOTE: this will be inherited from the encounters record, so we dont want a default
                //defaultValue: 'DCM: Surgery Services',
                allowBlank: false
            }
        },
        'study.encounters': {
            type: {
                defaultValue: 'Surgery',
                hidden: true
            },
            title: {
                hidden: true
            },
            caseno: {
                hidden: true
            },
            procedureid: {
                lookup: {
                    filterArray: [
                        LABKEY.Filter.create('category', 'Surgery;Procedure', LABKEY.Filter.Types.EQUALS_ONE_OF),
                        LABKEY.Filter.create('active', true, LABKEY.Filter.Types.EQUAL)
                    ]
                }
            },
            performedby: {
                hidden: true
            },
            remark: {
                hidden: true
            },
            chargetype: {
                allowBlank: false
            },
            assistingstaff: {
                hidden: false,
                allowBlank: true //will be handled in trigger script
            },
            enddate: {
                editorConfig: {
                    getDefaultDate: function(){
                        var rec = EHR.DataEntryUtils.getBoundRecord(this);
                        if (rec){
                            if (rec.get('date')){
                                return rec.get('date');
                            }
                        }
                    }
                }
            }
        },
        'ehr.snomed_tags': {
            code: {
                editorConfig: {
                    xtype: 'ehr-snomedcombo',
                    defaultSubset: 'Diagnostic Codes'
                }
            },
            set_number: {
                hidden: true
            },
            sort: {
                hidden: true
            }
        },
        'ehr.encounter_participants': {
            comment: {
                hidden: false,
                header: 'Remarks',
                columnConfig: {
                    width: 300
                }
            }
        },
        'ehr.encounter_summaries': {
            category: {
                defaultValue: 'Narrative'
            }
        }
    }
});