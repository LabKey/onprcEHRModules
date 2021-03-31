
/**
 * User: Kolli
 * Date: 7/14/19
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('CT', {
    allQueries: {

    },
    byQuery: {
        'study.PMIC_CTImagingData': {
            PMICType: {
                allowBlank: true,
                defaultValue: 'CT',
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
                columnConfig: {
                    width: 150
                }
            },

            chargeType: {
                allowBlank: true,
                defaultValue: 'PMIC',
                hidden: false
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

            CTType: {
                columnConfig: {
                    width: 150
                }
            },

            CTScanRange: {
                header:"CT Scan Range(mm)",
                columnConfig: {
                    width: 150
                }
            },

            ContrastType: {
                // xtype: 'combo',
                // hidden: false,
                // lookup: {
                //     schemaName: 'study',
                //     queryName: 'PMIC_CTContrastType_values',
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

            ContrastAmount: {
                header: 'Contrast Amount (ml)',
                hidden: false,
                columnConfig: {
                    width: 200
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
