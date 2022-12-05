
/**
 * User: Kolli
 * Date: 7/14/19
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('Angio', {
    allQueries: {
    },
    byQuery: {
        'study.PMIC_AngioImagingData': {
            PMICType: {
                allowBlank: true,
                defaultValue: 'Angio',
                hidden: false
            },

            Date: {
                header:'Exam Date',
                columnConfig: {
                    width: 200
                }
            },

            project: {
                xtype: 'onprc_ehr-projectentryfield',
                allowBlank: true,
                hidden: false,
                columnConfig: {
                    width: 150
                }
            },

            chargeType: {
                allowBlank: true,
                defaultValue: 'PMIC',
                hidden: false,
                editable: false
            },

            examNum: {
                header:"Exam Num",
                columnConfig: {
                    width: 150
                }
            },

            accessionNum: {
                header:"Accession Num",
                columnConfig: {
                    width: 150
                }
            },

            CTDIvol: {
                header:"CTDIVol (mGy)",
                columnConfig: {
                    width: 150
                }
            },

            DLP: {
                header:"DLP (mGy*cm)",
                columnConfig: {
                    width: 150
                }
            },

            wetLabUse: {
                header:"Wet lab use",
                defaultValue: 'No',
                columnConfig: {
                    width: 150
                }
            },

            ImageUploadLink: {
                hidden: true,
                columnConfig: {
                    width: 150
                }
            },

            TotalExamDLP: {
                hidden: true,
                header: 'Total Exam DLP (mGy*cm)',
                columnConfig: {
                    width: 200
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