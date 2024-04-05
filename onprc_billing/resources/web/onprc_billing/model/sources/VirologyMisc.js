/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */


EHR.model.DataModelManager.registerMetadata('VirologyMisc', {
    allQueries: {
    },
    byQuery: {
        'onprc_billing.miscCharges': {
            Id: {
                hidden: false,
                header: 'Animal Id'
            },

            chargeId: {
                xtype: 'combo',
                header: 'Charge Name',
                hidden: false,
                lookup: {
                    schemaName: 'onprc_billing',
                    queryName: 'virologyBillingCharges',
                    displayColumn: 'chargeName',
                    keyColumn: 'rowid',
                    columns: 'rowid, category, chargeName, unitCost'
                },
                editorConfig: {
                    listConfig: {
                        //innerTpl: '{[(values.category ? "<b>" + values.category + ":</b> " : "") + values.chargeName]}',
                        innerTpl: '{[("<b>" + LABKEY.Utils.encodeHtml(values.chargeName) + "</b>" )]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                },
                columnConfig: {
                    width: 400
                }

            },

            debitedaccount: {
                xtype: 'combo',
                header: 'Alias',
                hidden: false,
                lookup: {
                    schemaName: 'onprc_billing',
                    queryName: 'virologyAliases',
                    displayColumn: 'aliasPI',
                    keyColumn: 'alias',
                    columns: 'alias, aliasPI'
                },
                editorConfig: {
                    listConfig: {
                        innerTpl: '{[("<b>" + LABKEY.Utils.encodeHtml(values.aliasPI) + "</b>" )]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                },
                columnConfig: {
                    width: 300
                }

            },

            project: {
                allowBlank: true,
                hidden: true
            },

            comment: {
                allowBlank: true,
                columnConfig: {
                    width: 200
                }
            },

            unitcost: {
                hidden: false,
                header: 'NIH Rate',
                editorConfig: {
                    decimalPrecision: 2
                }
            },

            lineItemTotal: {
                allowBlank: true,
                header: 'Estimated Charge',
                nullable: true,
                hidden: false,
                shownInGrid: true,
                columnConfig: {
                    width: 200
                }
            },

            chargetype: {
                allowBlank: true,
                defaultValue: 'Virology Core',
                hidden: false
            }

        }
    }
});