
/**
 * User: Kolli
 * Date: 02/20/2020
 */
EHR.model.DataModelManager.registerMetadata('StudyDetails', {
    allQueries: {
    },

    byQuery: {
        'study.StudyDetails': {

            Date: {
                header:'Start Date',
                columnConfig: {
                    width: 200
                }
            },

            endDate: {
                header:'End Date',
                columnConfig: {
                    width: 200
                }
            },

            project: {
                allowBlank: true,
                columnConfig: {
                    width: 150
                }
            },

            studyCohort: {
                header:"Study Cohort",
                columnConfig: {
                    width: 125
                }
            },

            // studyGroup: {
            //     header:"Study Group",
            //     lookup: {
            //         schemaName: 'study',
            //         queryName: 'StudyDetails_group_values',
            //         sort: 'sort_order',
            //         columns: 'value, name'
            //     },
            //     columnConfig: {
            //         width: 100
            //     }
            // },

            studyGroupNum: {
                header:"Study Group #",
                lookup: {
                    schemaName: 'study',
                    queryName: 'StudyDetails_cohort_values',
                    sort: 'sort_order',
                    columns: 'value, name'
                },
                columnConfig: {
                    width: 125
                }
            },

            studyPhase: {
                header:"Study Phase",
                lookup: {
                    schemaName: 'study',
                    queryName: 'StudyDetails_phase_values',
                    sort: 'sort_order',
                    columns: 'value, name'
                },
                columnConfig: {
                    width: 100
                }
            },

            remark: {
                header:'Remark',
                columnConfig: {
                    width: 200
                }
            },

            performedby: {
                defaultValue: LABKEY.Security.currentUser.displayName ,
                hidden: false
            }

        }

    }
});
