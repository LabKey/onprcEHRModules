/**
 * User: Kolli
 * Date: 4/10/2020
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('Staining', {
    allQueries: {
    },

    byQuery: {
        'study.IPC_Staining': {

            tissueType: {
                columnConfig: {
                    width: 250
                }
            },

            HAndE: {
                header:"H&E",
                columnConfig: {
                    width: 150
                }
            },

            specialStain: {
                header:"Special Stain",
                columnConfig: {
                    width: 150
                }
            },

            IHC: {
                header:"IHC",
                columnConfig: {
                    width: 150
                }
            },

            IHCPrimaryAntibody: {
                header:"IHC Primary Antibody",
                hidden: false,
                columnConfig: {
                    width: 200
                }
            },

            irrelevantAntibody: {
                header:"Irrelevant Antibody",
                hidden: false,
                columnConfig: {
                    width: 200
                }
            },

            RNAScope: {
                header:"RNA Scope",
                hidden: false,
                columnConfig: {
                    width: 150
                }
            },

            other: {
                header:"Other",
                hidden: false,
                columnConfig: {
                    width: 150
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
