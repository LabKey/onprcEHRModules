/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.DataEntryUtils.registerDataEntryFormButton('ENTERDEATH', {
    text: 'Enter/Manage Death',
    name: 'enterdeath',
    itemId: 'enterdeath',
    tooltip: 'Click to enter the death record for this animal',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in ENTERDEATH button', panel);

        var store = panel.storeCollection.getClientStoreByName('encounters');
        LDK.Assert.assertNotEmpty('Unable to find encounters store in ENTERDEATH button', store);
        LDK.Assert.assertEquality('Expected to find only 1 record in encounters store in ENTERDEATH button.', 1, store.getCount());

        if (!store || store.getCount() != 1){
            Ext4.Msg.alert('Error', 'Unable to find animal ID.  Please contact your administrator');
            return;
        }

        var animalId = store.getAt(0).get('Id');
        var caseno = store.getAt(0).get('caseno');
        var parentid = store.getAt(0).get('objectid');

        if (!animalId){
            Ext4.Msg.alert('Error', 'You must enter an Animal Id');
            return;
        }

        Ext4.Msg.wait('Loading...');
        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'deaths',
            filterArray: [LABKEY.Filter.create('Id', animalId)],
            columns: 'Id,objectid',
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: function (results) {
                Ext4.Msg.hide();

                var objectid = null;
                if (results && results.rows && results.rows.length) {
                    objectid = results.rows[0].objectid;
                }

                Ext4.create('EHR.window.ManageRecordWindow', {
                    schemaName: 'study',
                    queryName: 'deaths',
                    pkCol: 'objectid',
                    pkValue: objectid || LABKEY.Utils.generateUUID().toUpperCase(),
                    extraMetaData: {
                        Id: {
                            defaultValue: animalId,
                            editable: false
                        },
                        necropsy: {
                            defaultValue: caseno
                        },
                        parentid: {
                            defaultValue: parentid
                        }
                    }
                }).show();
            }
        });
    }
});

EHR.DataEntryUtils.registerDataEntryFormButton('ENTERDEATH_FOR_TISSUES', {
    text: 'Enter/Manage Death',
    name: 'enterdeath',
    itemId: 'enterdeath',
    tooltip: 'Click to enter the death record for this animal',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in ENTERDEATH button', panel);

        var ids = [];

        panel.storeCollection.clientStores.each(function(clientStore){
            if (clientStore.getFields().get('Id')){
                clientStore.each(function(r){
                    if (r.get('Id')){
                        ids.push(r.get('Id'));
                    }
                }, this);
            }
        }, this);

        ids = Ext4.unique(ids);
        if (!ids.length){
            Ext4.Msg.alert('Error', 'No animals have been entered in this form');
            return;
        }
        else if (ids.length > 1){
            var data = [];
            Ext4.Array.forEach(ids, function(id){
                data.push({
                    value: id
                })
            }, this);

            Ext4.create('Ext.window.Window', {
                title: 'Choose Animal',
                width: 350,
                modal: true,
                closeAction: 'destroy',
                bodyStyle: 'padding: 5px;',
                doLoad: doLoad,
                defaults: {
                    border: false
                },
                items: [{
                    html: 'There are multiple animals in this form. Please choose one below',
                    style: 'padding-bottom: 10px;'
                },{
                    xtype: 'combo',
                    fieldLabel: 'Choose Id',
                    valueField: 'value',
                    displayField: 'value',
                    width: 300,
                    itemId: 'animalField',
                    store: {
                        proxy: {
                            type: 'memory'
                        },
                        type: 'json',
                        fields: ['value'],
                        data: data
                    }
                }],
                buttons: [{
                    text: 'Submit',
                    scope: this,
                    handler: function(btn){
                        var id = btn.up('window').down('#animalField').getValue();
                        if (!id){
                            Ext4.Msg.alert('Error', 'Must choose an animal');
                            return;
                        }

                        var win = btn.up('window');
                        win.doLoad(id);
                        win.close();
                    }
                },{
                    text: 'Close',
                    handler: function(btn){
                        btn.up('window').close();
                    }
                }]
            }).show();
        }
        else {
            doLoad(ids[0]);
        }

        function doLoad(animalId){
            Ext4.Msg.wait('Loading...');
            EHR.DemographicsCache.getDemographics(animalId, function(ids, ret){
                Ext4.Msg.hide();

                var ar = ret[animalId];
                if (!ar){
                    Ext4.Msg.alert('Error', 'Unable to find a demographics record for animal: ' + animalId);
                    return;
                }

                var objectid = null;
                if (ar.getDeathInfo() && ar.getDeathInfo().length){
                    objectid = ar.getDeathInfo()[0].objectid;
                }

                Ext4.create('EHR.window.ManageRecordWindow', {
                    schemaName: 'study',
                    queryName: 'deaths',
                    pkCol: 'objectid',
                    pkValue: objectid || LABKEY.Utils.generateUUID().toUpperCase(),
                    extraMetaData: {
                        Id: {
                            defaultValue: animalId,
                            editable: false
                        }
                    }
                }).show();
            }, this);
        }
    }
});

EHR.DataEntryUtils.registerGridButton('RESET_SORT_ORDER', function(config){
    return Ext4.Object.merge({
        text: 'Reset Sort Order',
        tooltip: 'Click to reset the sort order on this grid, updating all records to match the order in which they are currently displayed',
        handler: function(btn){
            Ext4.Msg.confirm('Reset Sort Order', 'This will reset the sort order column on all rows to match the order in which they are currently displayed.  Do you want to proceed?', function(val){
                if (val == 'yes') {
                    //NOTE: batch changes so we dont overwhelm PathologyDiagnosesStore with updates
                    var grid = btn.up('gridpanel');
                    var changed = [];
                    grid.store.each(function (rec, idx) {
                        if (rec.get('sort_order') !== (idx + 1)) {
                            changed.push(rec);
                            rec.beginEdit();
                            rec.set('sort_order', (idx + 1));
                            rec.endEdit(true);
                        }
                    }, this);

                    if (changed.length) {
                        Ext4.Array.forEach(changed, function (r) {
                            grid.store.fireEvent('update', grid.store, r);
                        }, this);
                    }
                }
            }, this);
        }
    }, config);
});