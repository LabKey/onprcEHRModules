
/**
 * User: Kolli
 * Date: 7/14/19
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('US', {
    allQueries: {
    },
    byQuery: {
        'study.PMIC_USImagingData': {
            PMICType: {
                allowBlank: true,
                defaultValue: 'Ultrasound',
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

            wetLabUse: {
                header:"Wet lab use",
                defaultValue: 'No',
                columnConfig: {
                    width: 150
                }
            },

            ultrasoundProcedure: {
                // xtype: 'combo',
                // header: "Ultrasound Procedure",
                // lookup: {
                //     schemaName: 'study',
                //     queryName: 'PMIC_US_values',
                //     displayColumn: 'value',
                //     columns: 'value, name'
                // },
                // editorConfig: {
                //     listConfig: {
                //         innerTpl: '{[("<b>" + values.value + "</b>" )]}',
                //         getInnerTpl: function () {
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