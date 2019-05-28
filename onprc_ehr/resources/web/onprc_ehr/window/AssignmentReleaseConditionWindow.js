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
Ext4.define('ONPRC_EHR.window.AssignmentReleaseConditionWindow', {
    extend: 'Ext.window.Window',
    schemaName: 'study',
    queryName: 'Assignment',
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

            Ext4.create('ONPRC_EHR.window.AssignmentReleaseConditionWindow', {
                dataRegionName: dataRegionName
            }).show();
        }
    },

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            title: 'Edit Release Condition',
            closeAction: 'destroy',
            width: 500,
            defaults: {
                width: 350,
                border: false
            },
            bodyStyle: 'padding: 5px;',
            items: [{
                html: 'This helper allows you to set the release condition in bulk.  It will only allow you to do this on assignments that have already been ended, and that lack a release condition.  This is intentional because of the possibility for large scale accidental changes causing problems with billing.  There is a separate helper that allows you to end the assignment and set release condition in a single step if that if your goal.' +
                '<br><br>Note: changing the release condition has billing implications, so make any changes carefully.',
                width: 470,
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'labkey-combo',
                fieldLabel: 'Release Condition',
                itemId: 'releaseConditionField',
                displayField: 'meaning',
                valueField: 'code',
                queryMode: 'local',
                listConfig: {
                    innerTpl: '{[values.meaning + " (" + values.code + ")"]}',
                    getInnerTpl: function(){
                        return this.innerTpl;
                    }
                },
                store: {
                    type: 'labkey-store',
                    schemaName: 'ehr_lookups',
                    queryName: 'animal_condition',
                    columns: 'code,meaning',
                    autoLoad: true,
                    sort: 'code'
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
    },

    onSubmit: function(btn){
        Ext4.Msg.wait('Loading...');
        var releaseCondition = this.down('#releaseConditionField').getValue();

        if (!releaseCondition){
            Ext4.Msg.alert('Error', 'Must enter a release condition');
            return;
        }

        var dataRegion = LABKEY.DataRegions[this.dataRegionName];
        var checked = dataRegion.getChecked();

        LABKEY.Query.selectRows({
            method: 'POST',
            schemaName: this.schemaName,
            queryName: this.queryName,
            columns: this.pkColName + ',enddate,releaseCondition',
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
        var releaseCondition = this.down('#releaseConditionField').getValue();

        if (!data.rows || !data.rows.length){
            Ext4.Msg.hide();
            Ext4.Msg.alert('Error', 'No rows found');
            dataRegion.selectNone();
            dataRegion.refresh();
            return;
        }

        Ext4.Array.forEach(data.rows, function(row){
            if (row.enddate && !row.releaseCondition){
                var obj = {
                    releaseCondition: releaseCondition
                };
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
                    Ext4.Msg.alert('Success', 'The assignments have been updated with a new release condition.' + (skipped.length ? '  Note: ' + skipped.length + ' row(s) were skipped because they have not yet ended or already have a release condition' : ''));

                    dataRegion.selectNone();
                    dataRegion.refresh();
                },
                failure: LDK.Utils.getErrorCallback()
            });
        }
        else {
            Ext4.Msg.hide();
            Ext4.Msg.alert('No Updates', 'There were no updates to make.' + (skipped.length ? '  Note:' + skipped.length + ' row(s) were skipped because they have not been ended or already has a release condition' : ''));
            dataRegion.selectNone();
            dataRegion.refresh();
        }
    }
});