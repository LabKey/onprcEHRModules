EHR.DataEntryUtils.registerGridButton('COPYFROMENCOUNTERS', function(config){
    return Ext4.Object.merge({
        text: 'Add Defaults',
        xtype: 'button',
        tooltip: 'Click to copy records from the encounters section',
        handler: function(btn){
            var grid = btn.up('grid');
            LDK.Assert.assertNotEmpty('Unable to find grid in COPYFROMENCOUNTERS button', grid);

            var panel = grid.up('ehr-dataentrypanel');
            LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in COPYFROMENCOUNTERS button', panel);

            var store = panel.storeCollection.getClientStoreByName('encounters');
            LDK.Assert.assertNotEmpty('Unable to find encounters store in COPYFROMENCOUNTERS button', store);

            if (store){
                Ext4.create('EHR.window.CopyFromEncountersWindow', {
                    targetGrid: grid,
                    targetTab: grid.title,
                    encountersStore: store
                }).show();
            }
        }
    });
});

EHR.DataEntryUtils.registerGridButton('SURGERYADD', function(config){
    return Ext4.Object.merge({
        text: 'Add Record',
        tooltip: 'Click to add a row',
        handler: function(btn){
            var grid = btn.up('gridpanel');
            if(!grid.store || !grid.store.hasLoaded()){
                console.log('no store or store hasnt loaded');
                return;
            }

            var panel = grid.up('ehr-dataentrypanel');
            LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in SURGERYADD button', panel);

            var store = panel.storeCollection.getClientStoreByName('encounters');
            LDK.Assert.assertNotEmpty('Unable to find encounters store in SURGERYADD button', store);

            Ext4.create('EHR.window.SurgeryAddRecordWindow', {
                targetGrid: grid,
                encountersStore: store
            }).show();
        }
    }, config);
});

EHR.DataEntryUtils.registerGridButton('SURGERYDELETE', function(config){
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
            var fieldName = 'parentid';
            Ext4.Array.each(selections, function(r){
                if (!r.canDelete()){
                    hasPermission = false;
                    return false;
                }

                LDK.Assert.assertNotEmpty('No encounterid in encounters record', r.get(fieldName));
                runIds.push(r.get(fieldName));
            }, this);

            //find children
            var childrenToDelete = {};
            var totalChildren = 0;
            if (hasPermission){
                grid.dataEntryPanel.storeCollection.clientStores.each(function(s){
                    if (!hasPermission)
                        return false;

                    if (s != grid.store){
                        if (!s.model.prototype.fields.containsKey(fieldName)){
                            console.log('no encounterid: ' + s.storeId);
                            return;
                        }

                        s.each(function(childRec){
                            if (runIds.indexOf(childRec.get(fieldName)) != -1){
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