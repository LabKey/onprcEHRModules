/**
 * User: Kolli
 * Date: 4/10/2020
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('SlidePrinting', {
    allQueries: {
    },
    byQuery: {
        'study.IPC_SlidePrinting': {

            tissueType: {
                columnConfig: {
                    width: 250
                }
            },

            projectNotes: {
                header:"Project Notes",
                hidden: false,
                columnConfig: {
                    width: 250
                }
            },

            additionalText: {
                header:"Additional text on slide",
                hidden: false,
                columnConfig: {
                    width: 250
                }
            },

            performedBy: {
                defaultValue: LABKEY.Security.currentUser.displayName,
                columnConfig: {
                    width: 150
                }
            }

        }

    }

});
