/**
 * User: Kolli
 * Date: 4/10/2020
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('ProcessingEmbedding', {
    allQueries: {
    },
    byQuery: {
        'study.IPC_ProcessingEmbedding': {

            tissueType: {
                columnConfig: {
                    width: 250
                }
            },

            embedding: {
                columnConfig: {
                    width: 200
                }
            },

            fixationMethod: {
                header:"Initial Fixative",
                columnConfig: {
                    width: 200
                }
            },

            fixationDuration: {
                header:"Fixation Duration",
                columnConfig: {
                    width: 150
                }
            },

            currentFixative: {
                header:"Current Fixative",
                columnConfig: {
                    width: 150
                }
            },

            processingType: {
                header:"Processing Type",
                columnConfig: {
                    width: 250
                }
            },

            embeddingIns: {
                header:"Embedding Instructions",
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
