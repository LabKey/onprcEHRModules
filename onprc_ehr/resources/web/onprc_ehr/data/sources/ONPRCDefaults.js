/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * The default metadata applied to all queries when using getTableMetadata().
 * This is the default metadata applied to all queries when using getTableMetadata().  If adding attributes designed to be applied
 * to a given query in all contexts, they should be added here
 */
EHR.model.DataModelManager.registerMetadata('Default', {
    byQuery: {
        'study.blood' : {
            tube_vol: {
                hidden: true
            },
            num_tubes: {
                hidden: true
            },
            quantity: {
                xtype: 'numberfield'
            }
        }
    }
});

EHR.model.DataModelManager.registerMetadata('Request', {
    byQuery: {
        'study.blood' : {
            quantity: {
                xtype: 'numberfield'
            },
            tube_vol: {
                nullable: true
            },
            num_tubes: {
                nullable: true
            }
        }
    }
});
