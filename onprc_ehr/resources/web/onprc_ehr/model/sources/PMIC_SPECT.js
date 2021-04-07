
/**
 * User: Kolli
 * Date: 7/14/19
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('SPECT', {
    allQueries: {
    },

    byQuery: {
        'study.PMIC_SPECTImagingData': {
            PMICType: {
                allowBlank: true,
                defaultValue: 'SPECT',
                hidden: false
            },

            Date: {
                header:'Exam Date',
                columnConfig: {
                    width: 200
                }
            },

            project: {
                allowBlank: true,
                hidden: true,
                columnConfig: {
                    width: 150
                }
            },

            chargeType: {
                allowBlank: true,
                defaultValue: 'PMIC',
                hidden: true
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

            CTDIVol: {
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

            SPECTDoseMCI: {
                header: 'SPECT Dose (mCi)',
                columnConfig: {
                    width: 200
                },
                editorConfig: {
                    decimalPrecision: 4
                }
            },
            /*
            The conversion is actually pretty simple [1mCi = 37MBq]
            */
            SPECTDoseMBQ: {
                xtype: 'ehr-PMIC_SPECTDoseCalcField',
                header: 'SPECT Dose (MBq)',
                columnConfig: {
                    width: 200
                },
                editorConfig: {
                    decimalPrecision: 4
                }
            },

            Route: {
                // xtype: 'combo',
                // lookup: {
                //     schemaName: 'study',
                //     queryName: 'PMIC_Route_values',
                //     displayColumn: 'value',
                //     columns: 'value, name'
                // },
                // editorConfig: {
                //     listConfig: {
                //         innerTpl: '{[("<b>" + values.value + "</b>" )]}',
                //         getInnerTpl: function(){
                //             return this.innerTpl;
                //         }
                //     }
                // },
                columnConfig: {
                    width: 150
                }
            },

            LigandAndComments: {
                header:'Ligand and Comments',
                columnConfig: {
                    width: 200
                }
            },

            SPECTIsotope: {
                // xtype: 'combo',
                // header: 'SPECT Radioisotope',
                // lookup: {
                //     schemaName: 'study',
                //     queryName: 'PMIC_SPECTRadioisotope_values',
                //     displayColumn: 'value',
                //     columns: 'value, name'
                // },
                // editorConfig: {
                //     listConfig: {
                //         innerTpl: '{[("<b>" + values.value + "</b>" )]}',
                //         getInnerTpl: function(){
                //             return this.innerTpl;
                //         }
                //     }
                // },
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
