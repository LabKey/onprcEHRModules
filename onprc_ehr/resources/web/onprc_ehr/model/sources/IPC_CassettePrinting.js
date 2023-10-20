/**
 * User: Kolli
 * Date: 4/10/2020
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('CassettePrinting', {
    allQueries: {
    },

    byQuery: {
        'study.IPC_CassettePrinting': {

            tissueType: {
                columnConfig: {
                    width: 250
                }
            },

            PILabel: {
                header:"Additional text on cassette",
                columnConfig: {
                    width: 200
                }
            },

            cassetteColor: {
                header:"Cassette Color",
                columnConfig: {
                    width: 200
                }
            },

            remark: {
                header:"Remark",
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
            // ,
            //
            // qcstate: {
            //     hidden: true,
            //     defaultValue: 21
            // }

        }

    }

});
