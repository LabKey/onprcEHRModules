
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('TB_TestObservation', {
    allQueries: {

    },
    byQuery: {
        'study.clinical_observations': {
            category: {
                xtype: 'combo',
                fieldLabel: 'Category',
                defaultValue: 'TB TST Score (72 hr)',
                displayField: 'value',
                valueField: 'value',

                store: {
                    type: 'labkey-store',
                    schemaName: 'sla',
                    queryName: 'Reference_Data',
                    filterArray: [LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                        LABKEY.Filter.create('columnName', 'TBTestObserveCategory', LABKEY.Filter.Types.EQUAL)],
                    autoLoad: true,
                    sort: 'sort_order'
                }

        },
            observation: {
                allowBlank: false,
                xtype: 'onprc_TB_TST_ObservationScores' ,
                defaultValue: 'Grade: 0',
                columnConfig: {
                    width: 200
                }
            },

            code:{ hidden: true},

            area:  {
                xtype: 'combo',
                fieldLabel: 'Area',
                 defaultValue: 'Right Eyelid',
                 displayField: 'label',
                 valueField: 'value',
                 store: {
                  type: 'labkey-store',
                    schemaName: 'study',
                     queryName: 'TBObservationArea',
                     autoLoad: true,
                 sort: 'sort_order'
                }
             }
        }

    }
});