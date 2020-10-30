
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 10-7-2019 R.Blasa

    EHR.model.DataModelManager.registerMetadata('TreatmentDrugsClinical', {
    allQueries: {

    },
    byQuery: {
        'study.drug': {
            category: {
                allowBlank: false,
                shownInGrid: false,
                defaultValue: 'Clinical'
            }
        }
    }
});