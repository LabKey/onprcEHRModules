
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('PMIC_Services', {
            allQueries: {

            },

            byQuery: {
                'study.encounters': {
                    chargetype: {
                        defaultValue: 'PMIC',
                        hidden: true
                    },
                    date: {
                        xtype: 'xdatetime',
                        extFormat: 'Y-m-d H:i',
                        defaultValue: (new Date()).format('Y-m-d 8:0')
                    },
                    type: {
                        defaultValue: 'Procedure',
                        hidden: true
                    },
                    procedureid: {
                        lookup: {
                            filterArray: [
                                LABKEY.Filter.create('category', 'PMIC', LABKEY.Filter.Types.EQUAL),
                                LABKEY.Filter.create('active', true, LABKEY.Filter.Types.EQUAL)
                            ]
                        }
                    }
                },

                'study.drug': {
                    chargetype: {
                        defaultValue: 'PMIC Services',
                        hidden: true
                    },
                    date: {
                        xtype: 'xdatetime',
                        extFormat: 'Y-m-d H:i',
                        defaultValue: (new Date()).format('Y-m-d 8:0')
                    },
                    Billable: {
                        defaultValue: 'Yes',
                        hidden: false
                    },
                    category: {
                        defaultValue: 'Research',
                        hidden: true
                    },
                    remark: {
                        header: 'Ligand and Comments',
                        hidden: false
                    },
                    reason: {
                        defaultValue: 'Research',
                        hidden: false
                    },
                    lot: {
                        hidden: true
                    },
                    code: {
                        editorConfig: {
                            defaultSubset: 'Research'
                        },
                        header: 'Radioisotopes'
                    }
                }

            }
        }
);