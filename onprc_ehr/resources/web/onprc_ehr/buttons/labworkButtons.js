/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.DataEntryUtils.registerGridButton('COPYFROMCLINPATHRUNS', function(config){
    return Ext4.Object.merge({
        text: 'Copy From Above',
        xtype: 'button',
        tooltip: 'Click to copy records from the clinpath runs section',
        handler: function(btn){
            var grid = btn.up('grid');
            LDK.Assert.assertNotEmpty('Unable to find grid in COPYFROMCLINPATHRUNS button', grid);

            var panel = grid.up('ehr-dataentrypanel');
            LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in COPYFROMCLINPATHRUNS button', panel);

            var store = panel.storeCollection.getClientStoreByName('Clinpath Runs');
            LDK.Assert.assertNotEmpty('Unable to find clinpath runs store in COPYFROMCLINPATHRUNS button', store);

            if (store){
                Ext4.create('EHR.window.CopyFromRunsWindow', {
                    targetGrid: grid,
                    dataset: grid.title,
                    runsStore: store
                }).show();
            }
        }
    });
});

EHR.DataEntryUtils.registerGridButton('LABWORKADD', function(config){
    return Ext4.Object.merge({
        text: 'Add',
        tooltip: 'Click to add a row',
        handler: function(btn){
            var grid = btn.up('gridpanel');
            if(!grid.store || !grid.store.hasLoaded()){
                console.log('no store or store hasnt loaded');
                return;
            }

            var panel = grid.up('ehr-dataentrypanel');
            LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in LABWORKADD button', panel);

            var store = panel.storeCollection.getClientStoreByName('Clinpath Runs');
            LDK.Assert.assertNotEmpty('Unable to find clinpath runs store in LABWORKADD button', store);

            Ext4.create('EHR.window.LabworkAddRecordWindow', {
                targetGrid: grid,
                runsStore: store,
                dataset: grid.title
            }).show();
        }
    }, config);
});

EHR.DataEntryUtils.registerGridButton('PANELDELETE', function(config){
    return Ext4.Object.merge({
        text: 'Delete Selected',
        tooltip: 'Click to delete selected rows',
        handler: function(btn){
            var grid = btn.up('gridpanel');
            var selections = grid.getSelectionModel().getSelection();

            if(!grid.store || !selections || !selections.length)
                return;

            var hasPermission = true;
            var runIds = [];
            Ext4.Array.each(selections, function(r){
                if (!r.canDelete()){
                    hasPermission = false;
                    return false;
                }

                LDK.Assert.assertNotEmpty('No runId in clinpathRuns record', r.get('runid'));
                runIds.push(r.get('runid'));
            }, this);

            //find children
            var childrenToDelete = {};
            var totalChildren = 0;
            if (hasPermission){
                grid.dataEntryPanel.storeCollection.clientStores.each(function(s){
                    if (!hasPermission)
                        return false;

                    if (s != grid.store){
                        if (!s.model.prototype.fields.containsKey('runid')){
                            return;
                        }

                        s.each(function(childRec){
                            if (runIds.indexOf(childRec.get('runid')) != -1){
                                childrenToDelete[s.storeId] = childrenToDelete[s.storeId] || [];
                                childrenToDelete[s.storeId].push(childRec);
                                totalChildren++;

                                if (!childRec.canDelete()){
                                    hasPermission = false;
                                    return false;
                                }
                            }
                        }, this);
                    }
                }, this);
            }

            if (hasPermission){
                Ext4.Msg.confirm('Confirm', 'You are about to permanently delete these records from this form, along with the ' + totalChildren + ' results associated with them.  It cannot be undone.  Are you sure you want to do this?', function(val){
                    if (val == 'yes'){
                        for (var storeId in childrenToDelete){
                            var store = grid.dataEntryPanel.storeCollection.clientStores.get(storeId);
                            LDK.Assert.assertNotEmpty('Unable to find store: ' + storeId, store);

                            store.safeRemove(childrenToDelete[storeId]);
                        }

                        grid.store.safeRemove(selections);
                    }
                }, this);
            }
            else {
                Ext4.Msg.alert('Error', 'You do not have permission to remove one or more of these records');
            }
        }
    }, config);
});