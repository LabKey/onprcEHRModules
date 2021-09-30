/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * Author: Kolli
 * Date: 1/13/2021
 * Time: 10:36 AM
 * ART Core Billing
  */

EHR.model.DataModelManager.registerMetadata('ARTCoreMisc', {
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
                    queryName: 'ARTCoreBillingCharges',
                    displayColumn: 'chargeName',
                    keyColumn: 'rowid',
                    columns: 'rowid, category, chargeName, unitCost'
                },
                editorConfig: {
                    listConfig: {
                        //innerTpl: '{[(values.category ? "<b>" + values.category + ":</b> " : "") + values.chargeName]}',
                        innerTpl: '{[("<b>" + values.chargeName + "</b>" )]}',
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
                    queryName: 'ARTCoreAliases',
                    displayColumn: 'aliasPI',
                    keyColumn: 'alias',
                    columns: 'alias, aliasPI'
                },
                editorConfig: {
                    listConfig: {
                        innerTpl: '{[("<b>" + values.aliasPI + "</b>" )]}',
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
                hidden: false,
                width: 200
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
                defaultValue: 'ART',
                hidden: false
            }

        }
    }
});

//Kolli 7/2020. Submit and Reload button submits the form data and reloads the billing page
EHR.DataEntryUtils.registerDataEntryFormButton('BILLINGRELOAD', {
    text: 'Submit And Reload',
    name: 'submit',
    requiredQC: 'Completed',
    targetQC: 'Completed',
    errorThreshold: 'INFO',
    successURL: LABKEY.ActionURL.buildURL('ehr', 'dataEntryForm.view', null, {formType: LABKEY.ActionURL.getParameter('formType')}),
    disabled: true,
    itemId: 'reloadBtn',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        Ext4.Msg.confirm('Reload Form', 'You are about to submit this form.  Do you want to do this?', function(v){
            if(v == 'yes')
                this.onSubmit(btn);
        }, this);
    },
    disableOn: 'WARN'

});

//Kolli 7/2020. Saves and closes the form data and brings the user to the ART core billing home page
EHR.DataEntryUtils.registerDataEntryFormButton('BILLINGSAVECLOSE', {
    text: 'Save & Close',
    name: 'closeBtn',
    requiredQC: 'In Progress',
    errorThreshold: 'WARN',
    successURL: '/project/ONPRC/Core%20Facilities/ART%20Core/begin.view?pageId=ART%20Core%20Billing',
    disabled: true,
    itemId: 'closeBtn',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        panel.onSubmit(btn);
    },
    disableOn: 'ERROR'

});

//Kolli 7/2020. Submits the form data and brings the user to the ART core billing home page
EHR.DataEntryUtils.registerDataEntryFormButton('BILLINGFINAL', {
    text: 'Submit Final',
    name: 'submit',
    requiredQC: 'Completed',
    targetQC: 'Completed',
    errorThreshold: 'INFO',
    successURL: '/project/ONPRC/Core%20Facilities/ART%20Core/begin.view?pageId=ART%20Core%20Billing',
    disabled: true,
    itemId: 'finalBtn',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        Ext4.Msg.confirm('Finalize Form', 'You are about to finalize this form.  Do you want to do this?', function(v){
            if(v == 'yes')
                this.onSubmit(btn);
        }, this);
    },
    disableOn: 'WARN'

});