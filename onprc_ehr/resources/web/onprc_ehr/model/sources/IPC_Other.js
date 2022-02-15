/**
 * User: Kolli
 * Date: 4/10/2020
 * Time: 10:36 AM
 */

EHR.model.DataModelManager.registerMetadata('IPC_Other', {
    allQueries: {
    },

    byQuery: {
        'study.IPC_Other': {

            tissueType: {
                columnConfig: {
                    width: 250
                }
            },

            serviceAndProducts: {
                header:"Service & Products",
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
