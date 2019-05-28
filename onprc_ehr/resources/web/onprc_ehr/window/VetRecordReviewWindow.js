/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.VetRecordReviewWindow', {
    extend: 'Ext.window.Window',

    statics: {
        buttonHandler: function(dataRegionName){
            var dataRegion = LABKEY.DataRegions[dataRegionName];
            var checked = dataRegion.getChecked();
            if (!checked || !checked.length){
                alert('No records selected');
                return;
            }

            Ext4.create('ONPRC_EHR.window.VetRecordReviewWindow', {
                dataRegionName: dataRegionName,
                checked: checked
            }).show();
        }
    },

    initComponent: function(){
        Ext4.apply(this, {
            title: 'Mark Reviewed',
            modal: true,
            closeAction: 'destroy',
            width: 400,
            defaults: {
                border: false
            },
            bodyStyle: 'padding: 5px;',
            items: [{
                html: 'This allows you to certify the selected rows as reviewed.  Do you want to do this?',
                style: 'padding-bottom: 10px;'
            }],
            buttons: [{
                text: 'Mark Reviewed',
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

        this.on('beforeshow', function(win){
            if (!EHR.Security.hasVetPermission()){
                Ext4.Msg.alert('Error', 'You do not have permission to perform Vet Review');
                return false;
            }
        }, this);
    },

    onSubmit: function(btn){
        var dataRegion = LABKEY.DataRegions[this.dataRegionName];
        LDK.Assert.assertNotEmpty('Unable to find DataRegion in VetRecordReviewWindow', dataRegion);

        var checked = dataRegion.getChecked();
        if (!checked.length){
            Ext4.Msg.alert('Error', 'No rows selected');
            return;
        }

        Ext4.Msg.wait('Saving...');
        LDK.Assert.assertNotEmpty('No PKs found for VetRecordReviewWindow', checked.join(''));

        var tableMap = {};
        Ext4.Array.forEach(checked, function(c){
            var parts = c.split('<>');
            if (!tableMap[parts[1]]){
                tableMap[parts[1]] = [];
            }

            tableMap[parts[1]].push({
                lsid: parts[0],
                vetreview: LABKEY.Security.currentUser.displayName,
                vetreviewdate: new Date()
            });
        }, this);

        var multi = new LABKEY.MultiRequest();
        for (var tableName in tableMap){
            multi.add(LABKEY.Query.updateRows, {
                method: 'POST',
                schemaName: 'study',
                queryName: tableName,
                rows: tableMap[tableName],
                failure: LDK.Utils.getErrorCallback(),
                scope: this
            });
        }

        multi.send(this.onSuccess, this);
    },

    onSuccess: function(){
        Ext4.Msg.hide();

        var dataRegion = LABKEY.DataRegions[this.dataRegionName];
        dataRegion.refresh();

        this.close();
    }
});