/*
 * Copyright (c) 2013-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EHR.DataEntryUtils.registerGridButton('COPYFROMCLINPATHRUNS', function(config){
    return Ext4.Object.merge({
        text: 'Copy From Above',
        xtype: 'button',
        tooltip: 'Click to copy records from the Panel/Services section',
        handler: function(btn){
            var grid = btn.up('grid');
            LDK.Assert.assertNotEmpty('Unable to find grid in COPYFROMCLINPATHRUNS button', grid);

            var panel = grid.up('ehr-dataentrypanel');
            LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in COPYFROMCLINPATHRUNS button', panel);

            var store = panel.storeCollection.getClientStoreByName('Clinpath Runs');
            LDK.Assert.assertNotEmpty('Unable to find clinpath runs store in COPYFROMCLINPATHRUNS button', store);

            //Modified 2-2-2016  Blasa
            if (store){
                Ext4.create('ONPRC_EHR.window.CopyFromRunsTemplateWindow', {
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

                LDK.Assert.assertNotEmpty('No objectid in clinpathRuns record', r.get('objectid'));
                if (r.get('objectid'))
                    runIds.push(r.get('objectid').toLowerCase());
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
                            var runid = childRec.get('runid') ? childRec.get('runid').toLowerCase() : null;
                            if (runIds.indexOf(runid) != -1){
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

EHR.DataEntryUtils.registerDataEntryFormButton('LABWORK_SUBMIT', {
    text: 'Submit Final',
    name: 'submit',
    requiredQC: 'Completed',
    targetQC: 'Completed',
    errorThreshold: 'INFO',
    successURL: LABKEY.ActionURL.getParameter('srcURL') || LABKEY.ActionURL.getParameter('returnUrl') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('ehr', 'enterData.view'),
    disabled: true,
    itemId: 'submitBtn',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in LABWORK_SUBMIT button', panel);

        //iterate all panels and make sure we have at least 1 result entered
        var clinpathRunsStore = panel.storeCollection.getClientStoreByName('Clinpath Runs') || panel.storeCollection.getClientStoreByName('clinpathRuns');
        LDK.Assert.assertNotEmpty('Unable to find clinpathRunsStore from LABWORK_SUBMIT button', clinpathRunsStore);

        var missingResults = [];
        clinpathRunsStore.each(function(r){
            var runId = r.get('objectid');
            var found = false;
            panel.storeCollection.clientStores.each(function(cs){
                if (!cs.getFields().get('runid')){
                    return;
                }

                if (cs.storeId.match('-clinpathRuns$') || cs.storeId.match('-Clinpath Runs$')){
                    return;
                }

                cs.each(function(cr){
                    if (cr.get('runid') == runId){
                        found = true;
                        return false;
                    }
                }, this);

                if (found){
                    return false;
                }
            }, this);

            if (!found){
                missingResults.push(r);
            }
        }, this);

        var msg = 'You are about to finalize this form.  Do you want to do this?';
        if (missingResults.length){
            msg  = 'You are about the finalize this form, but the following panels do not have results entered.  Do you want to finalize anyway?<br>';
            Ext4.Array.forEach(missingResults, function(r){
                msg += '<br>' + (r.get('Id') || 'No Animal Entered') + ': ' + (r.get('servicerequested') || 'No Service Entered');
            }, this);
        }

        Ext4.Msg.confirm('Finalize Form', msg, function (v) {
            if (v == 'yes')
                this.onSubmit(btn);
        }, this);
    },
    disableOn: 'WARN'
});
