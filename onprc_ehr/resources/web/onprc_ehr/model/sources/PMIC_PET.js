
/**
 * User: Kolli
 * Date: 7/14/19
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('PET', {
    allQueries: {
    },

    byQuery: {
        'study.PMIC_PETImagingData': {
            PMICType: {
                allowBlank: true,
                defaultValue: 'PET',
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
                hidden: false,
                defaultValue: 'PMIC',
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
                    width: 200
                }
            },

            PETDoseMCI: {
                header:"PET Dose (mCi)",
                columnConfig: {
                    width: 200
                },
                editorConfig: {
                    decimalPrecision: 4
                }
            },

            PETDoseMBQ: {
                /*
                The conversion is actually pretty simple [1mCi = 37MBq]
                */
                xtype: 'ehr-PMIC_DoseCalcField',
                header:"PET Dose (MBq)",
                columnConfig: {
                    width: 200
                },
                editorConfig: {
                    decimalPrecision: 4
                }
            },

            CTACType: {
                columnConfig: {
                    width: 150
                }
            },

            PETRadioIsotope: {
                columnConfig: {
                    width: 350
                }
            },

            route: {
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

            CTACScanRange: {
                header:"CT Scan Range(mm)",
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

            CTDIVol: {
                header:"CTDIVol (mGy)",
                columnConfig: {
                    width: 150
                }
            },

            phantom: {
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

            imageUploadLink: {
                hidden: true,
                columnConfig: {
                    width: 150
                }
            },

            ligandAndComments: {
                header:'Ligand and Comments',
                columnConfig: {
                    width: 200
                }
            },

            totalExamDLP: {
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
