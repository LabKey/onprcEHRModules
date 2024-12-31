
/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */


EHR.model.DataModelManager.registerMetadata('CMU_Services', {
    allQueries: {

    },
    byQuery: {
   'study.treatment_order': {
              chargetype: {
                  defaultValue: 'Research Staff',
                  hidden: false
              },
              date: {
                  defaultValue: new Date()
              },
              Billable: {
                  defaultValue: 'No',
                  hidden: true
              },
              code: {
                  header: 'Treatment',
                  editorConfig: {
                      defaultSubset: 'Research'
                  }
              },
              category: {
                  defaultValue: 'Research',
                  hidden: true
              },
              remark: {
                  header: 'Special Instructions',
                  hidden: false
              }
          },

        'ehr.requests': {
                    remark: {
                        label: 'Lab Phone # ',
                        width: 300,
                        height: 20,
                        hidden: false
                    }

        }
    }
});