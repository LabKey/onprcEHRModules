/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataRegionName
 * @cfg schemaName
 * @cfg queryName
 */
Ext4.define('ONPRC_EHR.window.MarkAnimalGroupCompletedWindow', {
    extend: 'Ext.window.Window',
    schemaName: 'study',
    queryName: 'animal_group_members',
    pkColName: 'lsid',
    targetField: 'enddate',

    statics: {
        buttonHandler: function(dataRegionName){
            var dataRegion = LABKEY.DataRegions[dataRegionName];

            var checked = dataRegion.getChecked();
            if (!checked || !checked.length){
                alert('No records selected');
                return;
            }

            Ext4.create('ONPRC_EHR.window.MarkAnimalGroupCompletedWindow', {
                dataRegionName: dataRegionName
            }).show();
        }
    },

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            title: 'Set End Date',
            closeAction: 'destroy',
            width: 500,
            defaults: {
                width: 350,
                border: false
            },
            bodyStyle: 'padding: 5px;',
            items: [{
                html: 'This helper allows you to end the selected animal group assignments.  You are required to choose the end date, and release type.',
                width: 470,
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'datefield',
                fieldLabel: 'Date',
                value: new Date(),
                itemId: 'dateField'
            },{
                xtype: 'labkey-combo',
                fieldLabel: 'Release Type',
                displayField: 'value',
                valueField: 'value',
                itemId: 'releaseTypeField',
                queryMode: 'local',
                store: {
                    type: 'labkey-store',
                    schemaName: 'ehr_lookups',
                    queryName: 'animalGroupReleaseType',
                    autoLoad: true
                }
            }],
            buttons: [{
                text:'Submit',
                disabled:false,
                scope: this,
                handler: this.onSubmit
            },{
                text: 'Close',
                handler: function(btn){
                    btn.up('window').close();
                }
            }]
        });

        this.callParent();

        LDK.Assert.assertNotEmpty('No pkColName provided to MarkCompletedWindow', this.pkColName);
    },

    onSubmit: function(btn){
        Ext4.Msg.wait('Loading...');
        var date = btn.up('window').down('#dateField').getValue();
        var releaseType = this.down('#releaseTypeField').getValue();
        if (!date || !releaseType){
            Ext4.Msg.alert('Error', 'Must enter a date and release type');
            return;
        }

        var dataRegion = LABKEY.DataRegions[this.dataRegionName];
        var checked = dataRegion.getChecked();

        LABKEY.Query.selectRows({
            method: 'POST',
            schemaName: this.schemaName,
            queryName: this.queryName,
            columns: this.pkColName + ',' + this.targetField,
            filterArray: [
                LABKEY.Filter.create(this.pkColName, checked.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)
            ],
            scope: this,
            success: this.onSuccess,
            failure: LDK.Utils.getErrorCallback()
        });
    },

    onSuccess: function(data){
        var toUpdate = [];
        var skipped = [];
        var dataRegion = LABKEY.DataRegions[this.dataRegionName];
        var date = this.down('#dateField').getValue();
        var releaseType = this.down('#releaseTypeField').getValue();

        if (!data.rows || !data.rows.length){
            Ext4.Msg.hide();
            Ext4.Msg.alert('Error', 'No rows found');
            dataRegion.selectNone();
            dataRegion.refresh();
            return;
        }

        Ext4.Array.forEach(data.rows, function(row){
            if (!row[this.targetField]){
                var obj = {
                    releaseType: releaseType
                };
                obj[this.targetField] = date;
                obj[this.pkColName] = row[this.pkColName];
                toUpdate.push(obj);
            }
            else {
                skipped.push(row[this.pkColName]);
            }
        }, this);

        if (toUpdate.length){
            LABKEY.Query.updateRows({
                method: 'POST',
                schemaName: this.schemaName,
                queryName: this.queryName,
                rows: toUpdate,
                scope: this,
                success: function(){
                    this.close();
                    Ext4.Msg.hide();
                    Ext4.Msg.alert('Success', 'The group assignments have been updated.' + (skipped.length ? '  Note: One or more rows was skipped because it already has an end date' : ''));

                    dataRegion.selectNone();
                    dataRegion.refresh();
                },
                failure: LDK.Utils.getErrorCallback()
            });
        }
        else {
            Ext4.Msg.hide();
            Ext4.Msg.alert('No Updates', 'There were no updates to make.' + (skipped.length ? '  Note: One or more rows was skipped because it already has an end date' : ''));
            dataRegion.selectNone();
            dataRegion.refresh();
        }
    }
});