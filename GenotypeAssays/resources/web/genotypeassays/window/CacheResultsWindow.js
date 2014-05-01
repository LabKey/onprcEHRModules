Ext4.define('GenotypeAssays.window.CacheResultsWindow', {
    extend: 'Ext.window.Window',

    statics: {
        showWindow: function(dataRegionName){
            var dr = LABKEY.DataRegions[dataRegionName];
            LDK.Assert.assertNotEmpty('Unable to find dataregion in CacheResultsWindow', dr);

            if (!dr.getChecked().length){
                Ext4.Msg.alert('Error', 'No rows selected');
                return;
            }

            Ext4.create('GenotypeAssays.window.CacheResultsWindow', {
                dataRegionName: dataRegionName
            }).show();
        }
    },

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            title: 'Cache Results',
            bodyStyle: 'padding: 5px;',
            closeAction: 'destroy',
            width: 500,
            defaults: {
                border: false
            },
            items: [{
                html: 'This will take a snapshot of the alignment results and store the summary in the Genotyping assay.  If any of the selected analyses have already been cached, this will replace the previously cached data with the current information.  Note: this will cache alignmented grouped on lineage, and only include rows where the percent is above the threshold selected below, and total lineages less than 3.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'combo',
                itemId: 'protocolField',
                width: 400,
                fieldLabel: 'Choose Assay',
                disabled: true,
                displayField: 'Name',
                valueField: 'RowId',
                queryMode: 'local',
                triggerAction: 'all',
                store: {
                    type: 'array',
                    proxy: {
                        type: 'memory'
                    },
                    fields: ['Name', 'RowId']
                }
            },{
                xtype: 'ldk-numberfield',
                width: 400,
                minValue: 0,
                maxValue: 100,
                value: 0.1,
                fieldLabel: 'Min Percent',
                itemId: 'pctThresholdField'
            }],
            buttons: [{
                text: 'Submit',
                scope: this,
                handler: this.onSubmit
            },{
                text: 'Cancel',
                handler: function(btn){
                    btn.up('window').close();
                }
            }]
        });

        LABKEY.Assay.getByType({
            type: 'Genotype Assay',
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: this.onLoad
        });

        this.callParent(arguments);
    },

    onLoad: function(results){
        if (!results || !results.length){
            Ext4.Msg.alert('Error', 'No suitable assays found');
            return;
        }

        var field = this.down('#protocolField');
        Ext4.Array.forEach(results, function(r){
            field.store.add({
                RowId: r.id,
                Name: r.name
            });
        }, this);

        if (results.length == 1){
            field.setValue(results[0].id);
        }
        field.setDisabled(false);
    },

    onSubmit: function(){
        var analysisIds = LABKEY.DataRegions[this.dataRegionName].getChecked();
        var protocol = this.down('#protocolField').getValue();
        var pctThreshold = this.down('#pctThresholdField').getValue();
        if (!analysisIds.length || !protocol){
            Ext4.Msg.alert('Error', 'Missing either analyses or the target assay');
        }

        Ext4.Msg.wait('Saving...');
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL('genotypeassays', 'cacheAnalyses', null, {analysisIds: analysisIds, protocolId: protocol, pctThreshold: pctThreshold}),
            method: 'post',
            timeout: 10000000,
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: LABKEY.Utils.getCallbackWrapper(function(results){
                Ext4.Msg.hide();
                this.close();

                if (results){
                    Ext4.Msg.confirm('Success', 'Results have been cached.  Do you want to view them now?', function(btn){
                        if (btn == 'yes'){
                            window.location = LABKEY.ActionURL.buildURL('assay', 'assayRuns', null, {rowId: protocol, 'Runs.RowId~in': results.runsCreated.join(';')});
                        }
                        else {
                            LABKEY.DataRegions[this.dataRegionName].refresh();
                        }
                    }, this);
                }
                else {
                    Ext4.Msg.alert('Error', 'Something may have gone wrong');
                }
            }, this)
        })
    }
});