/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.ReverseChargeWindow', {
    extend: 'Ext.window.Window',

    statics: {
        buttonHandler: function(dataRegionName){
            var dataRegion = LABKEY.DataRegions[dataRegionName];
            var checked = dataRegion.getChecked();
            if (!checked.length){
                Ext4.Msg.alert('Error', 'No rows selected');
                return;
            }

            Ext4.create('ONPRC_EHR.window.ReverseChargeWindow', {
                dataRegionName: dataRegionName
            }).show();
        }
    },

    initComponent: function(){
        var dataRegion = LABKEY.DataRegions[this.dataRegionName];
        this.checked = dataRegion.getChecked();

        this.ehrCtx = EHR.Utils.getEHRContext();
        if (!this.ehrCtx){
            Ext4.Msg.alert('Error', 'Unable to find the EHR container, aborting.');
            return;
        }

        LABKEY.ExtAdapter.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Reverse/Adjust Charges',
            width: 700,
            bodyStyle: 'padding: 5px;',
            defaults: {
                border: false
            },
            items: [{
                html: 'You have selected ' + this.checked.length + ' items to be reversed or adjusted.  If the billing period has not yet been marked final, the charge will simply be removed.  If the invoice period has been marked final, a new charge will be created to reverse the original.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'radiogroup',
                itemId: 'reversalType',
                columns: 1,
                fieldLabel: 'Reversal Type',
                defaults: {
                    xtype: 'radio',
                    name: 'reversalType'
                },
                listeners: {
                    scope: this,
                    change: this.onChange
                },
                items: [{
                    boxLabel: 'Reverse Charge Only',
                    inputValue: 'reversal',
                    checked: true
                },{
                    boxLabel: 'Change Project (Debit Side)',
                    inputValue: 'changeProject'
                },{
                    boxLabel: 'Change Credit Alias',
                    inputValue: 'changeCreditAlias'
                },{
                    boxLabel: 'Change Unit Cost',
                    inputValue: 'changeUnitCost'
                },{
                    boxLabel: 'Mark As Errored By IBS',
                    inputValue: 'markErrored'
                }]
            },{
                xtype: 'panel',
                itemId: 'itemArea',
                defaults: {
                    border: false
                },
                border: false,
                style: 'padding-top: 10px;'
            }],
            buttons: [{
                text: 'Submit',
                handler: this.onSubmit,
                scope: this
            },{
                text: 'Cancel',
                handler: function(btn){
                    btn.up('window').close();
                }
            }]
        });

        this.callParent(arguments);

        this.on('render', function(window){
            var group = window.down('radiogroup');
            group.fireEvent('change', group, group.getValue());
        }, this, {single: true});

        LDK.Assert.assertNotEmpty('No GUIDs found', this.checked.join(''));

        Ext4.Msg.wait('Loading...');
        LABKEY.Query.selectRows({
            method: 'POST',
            schemaName: 'onprc_billing',
            queryName: 'invoicedItems',
            requiredVersion: 9.1,
            filterArray: [
                LABKEY.Filter.create('objectid', this.checked.join(';'), LABKEY.Filter.Types.IN)
            ],
            columns: 'rowid,objectid,invoiceid,invoiceid/status,Id,date,project,creditedaccount,debitedaccount,rateId,exemptionId,quantity,investigatorId,chargeid,unitcost',
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: this.onDataLoad
        });
    },

    onDataLoad: function(results){
        this.selectRowsResults = results;

        Ext4.Msg.hide();
    },

    onChange: function(field){
        var val = field.getValue().reversalType;

        var items = [];
        if (val == 'reversal'){
            items.push({
                html: 'This will credit the debited account and charge the credited account',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'textarea',
                itemId: 'comment',
                width: 400,
                fieldLabel: 'Comment'
            });
        }
        else if (val == 'changeProject'){
            items.push({
                html: 'This will switch the project charged to the project selected below.  This will automatically create a charge to reverse the original charge, and create a second charge against the new project.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ehr-projectfield',
                itemId: 'projectField',
                showAccount: true,
                width: 400,
                fieldLabel: 'Choose Project',
                matchFieldWidth: false
//                listeners: {
//                    change: function(field){
//                        var panel = field.up('panel');
//                        var aliasField = panel.down('#aliasField');
//                        var recIdx = field.store.find('project', field.getValue());
//                        var rec;
//                        if (recIdx != -1){
//                            rec = field.store.getAt(recIdx);
//                        }
//
//                        if (rec){
//                            aliasField.setValue(rec.get('account'));
//                        }
//                    }
//                }
//            },{
//                xtype: 'labkey-combo',
//                width: 400,
//                fieldLabel: 'Choose Alias',
//                itemId: 'aliasField',
//                displayField: 'alias',
//                valueField: 'alias',
//                store: {
//                    type: 'labkey-store',
//                    schemaName: 'onprc_billing',
//                    queryName: 'aliases',
//                    autoLoad: true
//                }
            },{
                xtype: 'textarea',
                itemId: 'comment',
                width: 400,
                fieldLabel: 'Comment'
            });
        }
        else if (val == 'changeCreditAlias'){
            items.push({
                html: 'This will switch the alias credited for the selected charges to the alias selected below.  This will reverse the original item and create a new record with this alias.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'labkey-combo',
                itemId: 'aliasField',
                width: 400,
                fieldLabel: 'Choose Alias',
                displayField: 'alias',
                valueField: 'alias',
                store: {
                    type: 'labkey-store',
                    schemaName: 'onprc_billing',
                    queryName: 'aliases',
                    autoLoad: true
                }
            },{
                xtype: 'textarea',
                itemId: 'comment',
                width: 400,
                fieldLabel: 'Comment'
            });
        }
        else if (val == 'changeUnitCost'){
            var unitCosts = [];
            Ext4.Array.forEach(this.selectRowsResults.rows, function(row){
                var sr = new LDK.SelectRowsRow(row);
                unitCosts.push(sr.getValue('unitcost'));
            }, this);
            unitCosts = Ext4.unique(unitCosts);

            items.push({
                html: 'This will switch the unit cost for the selected charges to the amount selected below.  This will reverse the original item and create a new record using the updated unit cost.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'numberfield',
                itemId: 'unitCostField',
                decimalPrecision: 2,
                hideTrigger: true,
                width: 400,
                fieldLabel: 'Choose Unit Cost',
                value: unitCosts.length == 1 ? unitCosts[0] : null
            },{
                xtype: 'textarea',
                itemId: 'comment',
                width: 400,
                fieldLabel: 'Comment'
            });
        }
        else if (val == 'markErrored'){
            items.push({
                html: 'This will mark the selected charges as errored by IBS.  This is intended to ensure the PRIMe record accurately matches what was actually sent to IBS.  This will zero out the item in PRIMe as though no transaction occurred.  If the charge was initially errored and then corrected and submitted, this is not the proper thing to do.  This should only be used to flag items that were not importing into IBS and will never be imported into IBS.',
                style: 'padding-bottom: 10px;'
            });
        }

        var target = this.down('#itemArea');
        target.removeAll();
        target.add(items);
    },

    onSubmit: function(){
        var combo = this.down('triggerfield');
        if (combo && !combo.getValue()){
            Ext4.Msg.alert('Error', 'Must choose a value');
            return;
        }

        var val = this.down('#reversalType').getValue().reversalType;
        var commentField = this.down('#comment');
        this.hide();

        var miscChargesInserts = [];
        var invoicedItemsUpdate = [];
        var objectIds = [];
        Ext4.Array.forEach(this.selectRowsResults.rows, function(row){
            var sr = new LDK.SelectRowsRow(row);
            var baseValues = {
                //transactionNumber: sr.getValue('transactionNumber'),
                Id: sr.getValue('Id'),
                date: sr.getValue('date'),
                billingDate: new Date(),
                project: sr.getValue('project'),
                debitedaccount: sr.getValue('debitedaccount'),
                creditedaccount: sr.getValue('creditedaccount'),
                investigatorId: sr.getValue('investigatorId'),
                chargeId: sr.getValue('chargeId'),
                quantity: sr.getValue('quantity'),
                comment: commentField ? commentField.getValue() : null,
                //only copy unit cost if using a non-standard value
                unitcost: sr.getValue('rateId') || sr.getValue('exemptionId') ? null : sr.getValue('unitcost'),
                //item: sr.getValue('item'),
                //itemCode: sr.getValue('itemCode'),
                //category: sr.getValue('category'),
                //servicecenter: sr.getValue('servicecenter'),
                //faid: sr.getValue('faid'),
                //lastName: sr.getValue('lastName'),
                //firstName: sr.getValue('firstName'),
                //department: sr.getValue('department'),
                //totalcost: sr.getValue('totalcost'),
                //rateId: sr.getValue('rateId'),
                //exemptionId: sr.getValue('exemptionId'),
                //creditaccountid: sr.getValue('creditaccountid'),
                sourceInvoicedItem: sr.getValue('objectid')
            };
            objectIds.push(sr.getValue('objectid'));

            if (val == 'reversal'){
                var toInsert = LABKEY.ExtAdapter.apply({}, baseValues);
                LABKEY.ExtAdapter.apply(toInsert, {
                    chargeType: 'Reversal',
                    unitcost: -1 * sr.getValue('unitcost')
                });

                miscChargesInserts.push(toInsert);
            }
            else if (val == 'changeProject'){
                //first create a charge to reverse the original
                var reversalCharge = LABKEY.ExtAdapter.apply({}, baseValues);
                LABKEY.ExtAdapter.apply(reversalCharge, {
                    chargeType: 'Reversal',
                    unitcost: -1 * sr.getValue('unitcost')
                });

                miscChargesInserts.push(reversalCharge);

                //then create one to charge against the new project/account
                var combo = this.down('#projectField');

                var newCharge = LABKEY.ExtAdapter.apply({}, baseValues);
                LABKEY.ExtAdapter.apply(newCharge, {
                    chargeType: 'Adjustment (Project Change)',
                    project: combo.getValue(),
                    debitedaccount: null
                });

                miscChargesInserts.push(newCharge);
            }
            else if (val == 'changeCreditAlias'){
                //first create a charge to reverse the original
                var reversalCharge = LABKEY.ExtAdapter.apply({}, baseValues);
                LABKEY.ExtAdapter.apply(reversalCharge, {
                    chargeType: 'Reversal',
                    unitcost: -1 * sr.getValue('unitcost')
                });

                miscChargesInserts.push(reversalCharge);

                //then create one to charge against the new project/account
                var combo = this.down('#aliasField');

                var newCharge = LABKEY.ExtAdapter.apply({}, baseValues);
                LABKEY.ExtAdapter.apply(newCharge, {
                    creditedaccount: combo.getValue(),
                    debitedaccount: null,
                    chargeType: 'Adjustment (Credit Alias Change)'
                });

                miscChargesInserts.push(newCharge);
            }
            else if (val == 'changeUnitCost'){
                //first create a charge to reverse the original
                var reversalCharge = LABKEY.ExtAdapter.apply({}, baseValues);
                LABKEY.ExtAdapter.apply(reversalCharge, {
                    chargeType: 'Reversal',
                    unitcost: -1 * sr.getValue('unitcost')
                });

                miscChargesInserts.push(reversalCharge);

                //then create one to charge against the new project/account
                var field = this.down('#unitCostField');

                var newCharge = LABKEY.ExtAdapter.apply({}, baseValues);
                LABKEY.ExtAdapter.apply(newCharge, {
                    chargeType: 'Adjustment',
                    unitcost: field.getValue()
                });

                miscChargesInserts.push(newCharge);
            }
            else if (val == 'markErrored'){
                invoicedItemsUpdate.push({
                    rowid: sr.getValue('rowid'),
                    objectid: sr.getValue('objectid'),
                    transactionType: 'ERROR',
                    totalcost: null
                });
            }
        }, this);

        this.close();
        if (miscChargesInserts.length){
            Ext4.Msg.wait('Saving...');
            Ext4.Array.forEach(miscChargesInserts, function(obj){
                obj.objectid = LABKEY.Utils.generateUUID();
            }, this);

            LABKEY.Query.insertRows({
                containerPath: this.ehrCtx['EHRStudyContainer'],
                schemaName: 'onprc_billing',
                queryName: 'miscCharges',
                scope: this,
                rows: miscChargesInserts,
                error: LDK.Utils.getErrorCallback(),
                success: function(results){
                    Ext4.Msg.hide();
                    Ext4.Msg.confirm('Success', 'Charges have been reversed/adjusted.  These changes will apply to the next billing period.  Do you want to view these now?', function(val){
                        if (val == 'yes'){
                            window.location = LABKEY.ActionURL.buildURL('query', 'executeQuery', this.ehrCtx['EHRStudyContainer'], {
                                schemaName: 'onprc_billing',
                                'query.queryName': 'miscCharges',
                                'query.viewName': 'Adjustment Detail',
                                'query.sourceInvoicedItem~in': objectIds.join(';')
                            });
                        }
                    }, this);
                }

            })
        }
        else if (invoicedItemsUpdate){
            Ext4.Msg.wait('Saving...');

            LABKEY.Query.updateRows({
                schemaName: 'onprc_billing',
                queryName: 'invoicedItems',
                scope: this,
                rows: invoicedItemsUpdate,
                error: LDK.Utils.getErrorCallback(),
                success: function(results){
                    Ext4.Msg.hide();
                    Ext4.Msg.alert('Success', 'The selected charges have been marked as errors.', function(){
                        var dataRegion = LABKEY.DataRegions[this.dataRegionName];
                        dataRegion.refresh();
                    }, this);
                }
            });
        }
        else {
            Ext4.Msg.alert('Error', 'There are no changes to make');
        }
    }
});