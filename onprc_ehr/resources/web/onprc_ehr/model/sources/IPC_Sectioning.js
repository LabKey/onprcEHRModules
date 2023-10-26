/**
 * User: Kolli
 * Date: 4/10/2020
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('Sectioning', {
    allQueries: {
    },
    byQuery: {
        'study.IPC_Sectioning': {

            tissueType: {
                columnConfig: {
                    width: 250
                }
            },

            paraffinSectioning: {
                header:"Paraffin Sectioning",
                columnConfig: {
                    width: 200
                }
            },

            sectionThickness: {
                header:"Paraffin Section Thickness",
                columnConfig: {
                    width: 200
                }
            },

            frozenSectioning: {
                header:"Frozen Section Thickness",
                columnConfig: {
                    width: 200
                }
            },

            specialIns: {
                header:"Special Instructions",
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
