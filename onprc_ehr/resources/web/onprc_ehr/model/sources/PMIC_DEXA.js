
/**
 * User: Kolli
 * Date: 7/14/19
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('DEXA', {
    allQueries: {
    },
    byQuery: {
        'study.PMIC_DEXAImagingData': {
            PMICType: {
                allowBlank: true,
                defaultValue: 'DEXA',
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
                    width: 150
                }
            },

            animalPosition: {
                // xtype: 'combo',
                // lookup: {
                //     schemaName: 'study',
                //     queryName: 'PMIC_DEXA_AnimalPosition_values',
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

            DEXAProcedure: {
                // xtype: 'combo',
                // header: "DEXA Procedure",
                // lookup: {
                //     schemaName: 'study',
                //     queryName: 'PMIC_DEXA_values',
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