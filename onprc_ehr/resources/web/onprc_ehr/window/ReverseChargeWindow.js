/*
 * Copyright (c) 2013 LabKey Corporation
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
                html: 'You have selected ' + this.checked.length + ' items to be reversed.  If the item has not yet been invoiced, the charge will be removed.  If the charge has already been invoiced, a new item will be created to reverse the original.',
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
                    boxLabel: 'Change The Debit Alias',
                    inputValue: 'changeDebitAlias'
                },{
                    boxLabel: 'Change The Project',
                    inputValue: 'changeProject'
                },{
                    boxLabel: 'Change The Credit Alias',
                    inputValue: 'changeCreditAlias'
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
    },

    onChange: function(field){
        var val = field.getValue().reversalType;

        var items = [];
        if (val == 'reversal'){
            items.push({
                html: 'This will credit the debited account and charge the credited account'
            });
        }
        else if (val == 'changeDebitAlias'){
            items.push({
                html: 'This will switch the alias debited for the select charges to the alias selected below.  If the items have already been invoiced, it will reverse the original credit and create a new record.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'labkey-combo',
                width: 400,
                fieldLabel: 'Choose Alias',
                displayField: 'account',
                valueField: 'account',
                store: {
                    type: 'labkey-store',
                    schemaName: 'onprc_billing',
                    queryName: 'projectAccountHistory',
                    autoLoad: true
                }
            });
        }
        else if (val == 'changeProject'){
            items.push({
                html: 'This will change the project associated with these selected records, and automatically update the debit alias to match the alias currently associated with that project.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ehr-projectfield',
                width: 400,
                fieldLabel: 'Choose Project',
                matchFieldWidth: false
            });
        }
        else if (val == 'changeCreditAlias'){
            items.push({
                html: 'This will switch the alias credited for the select charges to the alias selected below.  If the items have already been invoiced, it will reverse the original credit and create a new record.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'labkey-combo',
                width: 400,
                fieldLabel: 'Choose Alias',
                displayField: 'account',
                valueField: 'account',
                store: {
                    type: 'labkey-store',
                    schemaName: 'onprc_billing',
                    queryName: 'projectAccountHistory',
                    autoLoad: true
                }
            });
        }


        var target = this.down('#itemArea');
        target.removeAll();
        target.add(items);
    },

    onSubmit: function(){
        var combo = this.down('combo');
        if (combo && !combo.getValue()){
            Ext4.Msg.alert('Error', 'Must choose a value');
            return;
        }
        LABKEY.Query.selectRows({
            schemaName: 'onprc_billing',
            queryName: 'invoicedItems',
            filterArray: [LABKEY.Filter.create('rowid', this.checked.join(';'), LABKEY.Filter.Types.IN)],
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: this.onLoad
        });

        Ext4.Msg.wait('Saving...');
    },

    onLoad: function(results){
        Ext4.Msg.hide();
        this.close();

        Ext4.Msg.alert('Completed', 'This will not currently make any changes to the data');
    }
});