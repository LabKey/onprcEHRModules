/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 6-8-2017   R.Blasa
EHR.model.DataModelManager.registerMetadata('AliasMisc', {
    allQueries: {
    },
    byQuery: {
        'onprc_billing.miscCharges': {
            debitedaccount: {
                xtype: 'textfield',
                header: 'Alias',
                width: 200,
                hidden: false
            },
            project: {
                allowBlank: true
            }
        }
    }
});