/*
 * Copyright (c) 2013-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.LockAnimalsPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc-lockanimalspanel',

    initComponent: function(){
        Ext4.apply(this, {
            bodyStyle: 'padding: 5px;',
            defaults: {
                border: false
            },
            items: [{
                html: 'The creation of new animals can be locked, in order to prevent the creation of new animals during processing.  The primary reason you would want to lock this form is to reserve a set of IDs before they have been entered into the computer.  When you lock the form, you will be prompted to enter the range of IDs you want to reserve.  You can choose to override the lock on this form, which will allow you to work on the form while keeping it locked for others.  This is not a fool-proof system, so if someone else has reserved a range of IDs please be aware of this.',
                style: 'padding-bottom: 10px;',
                maxWidth: 1000
            },{
                itemId: 'infoArea',
                border: false
            },{
                layout: 'hbox',
                defaults: {
                    style: 'margin-right: 5px;'
                },
                items: [{
                    xtype: 'button',
                    itemId: 'lockBtn',
                    text: 'Lock Entry',
                    scope: this,
                    locked: true,
                    handler: this.lockRecords
                },{
                    xtype: 'button',
                    itemId: 'overrideBtn',
                    text: 'Override Lock In This Form',
                    scope: this,
                    hidden: true,
                    locked: true,
                    handler: function(){
                        this.togglePanelItems(false);
                    }
                }]
            }]
        });

        this.callParent(arguments);

        var query = Ext4.ComponentQuery.query('ehr-dataentrypanel');
        LDK.Assert.assertTrue('Unable to find data entry panel', (query && query.length));
        if (query && query.length){
            this.dataEntryPanel = query[0];
        }

        LABKEY.Ajax.request({
            url: LABKEY.ActionURL.buildURL('onprc_ehr', 'getAnimalLock'),
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: LABKEY.Utils.getCallbackWrapper(this.onSuccess, this)
        });
    },

    onSuccess: function(results){
        var target = this.down('#infoArea');
        target.removeAll();
        if (results.locked){
            target.add({
                html: [
                    'Locked By: ' + results.lockedBy,
                    'Locked On: ' + results.lockDate,
                    (results.startingId ? 'First Reserved Id: ' + results.startingId : ''),
                    (results.idCount ? 'Last Reserved Id: ' + (results.startingId + results.idCount - 1) : '')
                ].join('<br>'),
                style: 'padding-bottom: 10px;',
                border: false
            });
        }

        this.togglePanel(!!results.locked);
    },

    lockRecords: function(btn){
        if (btn.locked) {
            Ext4.create('Ext.window.Window', {
                title: 'Enter ID Range',
                bodyStyle: 'padding: 5px;',
                ownerPanel: btn.up('onprc-lockanimalspanel'),
                items: [{
                    xtype: 'ehr-animalgeneratorfield',
                    fieldLabel: 'Starting Id',
                    itemId: 'startingId'
                },{
                    xtype: 'ldk-integerfield',
                    fieldLabel: '# of IDs to Reserve',
                    itemId: 'idCount'
                }],
                buttons: [{
                    text: 'Submit',
                    handler: function (btn) {
                        var win = btn.up('window');
                        var panel = win.ownerPanel;

                        var startingId = win.down('#startingId').getValue();
                        var idCount = win.down('#idCount').getValue();
                        if (!startingId || !idCount) {
                            Ext4.Msg.alert('Error', 'Must enter the starting animal ID and number of IDs to reserve.');
                            return;
                        }

                        LABKEY.Ajax.request({
                            url: LABKEY.ActionURL.buildURL('onprc_ehr', 'setAnimalLock'),
                            scope: this,
                            failure: LDK.Utils.getErrorCallback(),
                            success: LABKEY.Utils.getCallbackWrapper(function (results) {
                                win.close();

                                panel.onSuccess(results);
                            }, this),
                            jsonData: {
                                lock: true,
                                startingId: startingId,
                                idCount: idCount
                            }
                        });
                    }
                },{
                    text: 'Cancel',
                    handler: function (btn) {
                        btn.up('window').close();
                    }
                }]
            }).show();
        }
        else {
            LABKEY.Ajax.request({
                url: LABKEY.ActionURL.buildURL('onprc_ehr', 'setAnimalLock'),
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: LABKEY.Utils.getCallbackWrapper(function (results) {
                    btn.up('onprc-lockanimalspanel').onSuccess(results);
                }, this),
                jsonData: {
                    lock: false
                }
            });
        }
    },

    togglePanel: function(locked){
        var btn = this.down('#lockBtn');
        btn.setText(locked ? 'Unlock Entry For All' : 'Lock Entry');
        btn.locked = !locked;

        var overrideBtn = this.down('#overrideBtn');
        overrideBtn.setVisible(locked);

        this.togglePanelItems(locked);
    },

    togglePanelItems: function(locked){
        var up = this.dataEntryPanel.getUpperPanel();
        if (!up)
            return;

        var ret;
        up.items.each(function(item){
            if (item.getId() != this.getId()){
                item.setDisabled(locked);
            }
        }, this);

        var bbar = up.getDockedItems('toolbar[dock="bottom"]')[0];
        bbar.setDisabled(locked);
    }
});