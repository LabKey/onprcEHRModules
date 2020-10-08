
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.model.DataModelManager.registerMetadata('Surgery_Blood', {
    allQueries: {

    },
    byQuery: {

        'study.blood': {

            date: {
                getInitialValue: function(v){
                    return v;
                }
            }

        },
        'study.treatment_order': {

            enddate: {
                hidden: false,
                extFormat: 'Y-m-d 23:59'
                }
            }

    }
});