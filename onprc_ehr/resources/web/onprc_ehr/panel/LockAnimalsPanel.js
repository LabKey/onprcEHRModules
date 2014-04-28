/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
                html: 'The creation of new animals can be locked, in order to prevent the creation of new animals during processing.',
                style: 'padding-bottom: 10px;'
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
                }]
            }]
        });

        this.callParent(arguments);

        var query = Ext4.ComponentQuery.query('ehr-dataentrypanel');
        LDK.Assert.assertTrue('Unable to find data entry panel', (query && query.length));
        if (query && query.length){
            this.dataEntryPanel = query[0];
        }

        Ext4.Ajax.request({
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
                html: ['Locked By: ' + results.lockedBy, 'Locked On: ' + results.lockDate].join('<br>'),
                style: 'padding-bottom: 10px;',
                border: false
            });
        }

        this.togglePanel(!!results.locked);
    },

    lockRecords: function(btn){
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('onprc_ehr', 'setAnimalLock'),
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: LABKEY.Utils.getCallbackWrapper(this.onSuccess, this),
            jsonData: {
                lock: !!btn.locked
            }
        });
    },

    togglePanel: function(locked){
        var btn = this.down('#lockBtn');
        btn.setText(locked ? 'Unlock Entry' : 'Lock Entry');
        btn.locked = !locked;

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