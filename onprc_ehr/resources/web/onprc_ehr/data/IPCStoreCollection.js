/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('EHR.data.IPCStoreCollection', {
    extend: 'EHR.data.TaskStoreCollection',

    getIPCStore: function(){
        if (this.IPCStore){
            return this.IPCStore;
        }

        this.IPCStore = this.getClientStoreByName('IPC_ServiceRequestDetails');
        LDK.Assert.assertNotEmpty('Unable to find IPC store in IPCStoreCollection', this.IPCStore);

        return this.IPCStore;
    },

    getIPCRecord: function(parentid){
        if (!parentid){
            return null;
        }

        var IPCStore = this.getIPCStore();
        var er;
        IPCStore.each(function(r){
            if (r.get('objectid') == parentid){
                er = r;
                return false;
            }
        }, this);

        return er;
    },

    onClientStoreUpdate: function(){
        this.doUpdateRecords();
        this.callParent(arguments);
    },

    setClientModelDefaults: function(model){
        this.callParent(arguments);

        var IPCStore = this.getIPCStore();
        if (model.store && model.store.storeId == IPCStore.storeId){
            console.log('is IPC service request, skipping');
            return;
        }

        if (IPCStore.getCount() == 1){
            if (model.fields.get('parentid') && model.get('parentid') == null){
                model.data.parentid = IPCStore.getAt(0).get('objectid');
            }
        }

        if (model.fields.get('parentid') && model.get('parentid')){
            //find matching IPC record and update fields if needed
            var parentRec = this.getIPCRecord(model.get('parentid'));
            if (parentRec){
                model.beginEdit();
                if (parentRec.get('Id') !== model.get('Id')){
                    model.set('Id', parentRec.get('Id'));
                }

                if (model.fields.get('date') && !model.get('date') && parentRec.get('date')){
                    model.set('date', parentRec.get('date'));
                }

                if (model.fields.get('project') && !model.get('project') && parentRec.get('project')){
                    model.set('project', parentRec.get('project'));
                }

                // if (model.fields.get('chargetype') && !model.get('chargetype') && parentRec.get('chargetype')){
                //     model.set('chargetype', parentRec.get('chargetype'));
                // }

                model.endEdit(true);
            }
        }
    },

    doUpdateRecords: function(){
        var IPCStore = this.getIPCStore();
        this.clientStores.each(function(cs){
            if (cs.storeId == IPCStore.storeId){
                return;
            }

            if (cs.getFields().get('Id') == null || cs.getFields().get('parentid') == null){
                return;
            }

            var isIPCChild = cs.model.prototype.sectionCfg.configSources && cs.model.prototype.sectionCfg.configSources.indexOf('IPCChild') > -1;
            cs.each(function(rec){
                var IPCRec = this.getIPCRecord(rec.get('parentid'));
                if (IPCRec != null){
                    var obj = {};
                    if (rec.get('Id') !== IPCRec.get('Id')){
                        //the goal of this is to allow specific sections to avoid inheriting the Id of the parent
                        if (isIPCChild || !IPCRec.get('Id'))
                            obj.Id = IPCRec.get('Id');

                        //if the ID doesnt match, clear parentid
                        if (!isIPCChild){
                            obj.parentid = null;
                        }
                    }

                    var pf = rec.fields.get('project');
                    if (pf && IPCRec.get('project')){
                        if (!rec.get('project')){
                            obj.project = IPCRec.get('project');
                        }
                        else if (pf.inheritFromParent && IPCRec.get('project') !== rec.get('project')){
                            obj.project = IPCRec.get('project');
                        }
                    }

                    // var cf = rec.fields.get('chargetype');
                    // if (cf && IPCRec.get('chargetype')){
                    //     if (!rec.get('chargetype') || cf.inheritDateFromParent){
                    //         obj.chargetype = IPCRec.get('chargetype');
                    //     }
                    // }

                    var df = rec.fields.get('date');
                    if (df && IPCRec.get('date')){
                        if (!rec.get('date') || df.inheritDateFromParent){
                            if (!Ext4.Date.isEqual(rec.get('date'), IPCRec.get('date')))
                                obj.date = IPCRec.get('date');
                        }
                    }

                    if (!Ext4.Object.isEmpty(obj)){
                        rec.beginEdit();
                        rec.set(obj);
                        rec.endEdit(true);

                        // this is a slight misuse of this event.  validation will queue and batch changes, rather than immediately updating each row
                        // individually.  this is better than doing them one-by-one in large grids
                        if (rec.store){
                            rec.store.fireEvent('validation', rec.store, rec);
                        }
                    }
                }

            }, this);
        }, this);
    }
});