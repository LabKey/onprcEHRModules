/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Added 5-24-2017 R.Blasa
Ext4.define('onprc_ehr.data.sources.PathologyTissuesStoreCollection', {
    extend: 'EHR.data.TaskStoreCollection',

    constructor: function(){
        this.callParent(arguments);
    },

    setClientModelDefaults: function(model){
        var vals = this.getDefaultValues();
        if (!Ext4.Object.isEmpty(vals)){
            var toSet = {};

            if (model.fields.get('Id') != null){
                toSet.Id = vals.Id;
                toSet.date = vals.date;
                toSet.project = vals.project;
            }


            if (!Ext4.isEmpty(toSet)){
                model.suspendEvents();
                model.set(toSet);
                model.resumeEvents();
            }
        }

        return this.callParent([model]);
    },

    getRemarksStore: function(){
        if (this.remarkStore){
            return this.remarkStore;
        }

        this.remarkStore = this.getClientStoreByName('encounters');
        LDK.Assert.assertNotEmpty('Unable to find Pathology tissue record store in PathologyTissuesReportStoreCollection', this.remarkStore);

        return this.remarkStore;
    },

    getRemarksRec: function(){
        var remarkStore = this.getRemarksStore();
        if (remarkStore){
            LDK.Assert.assertTrue('More than 1 record found in Pathology Tissues store, actual: ' + remarkStore.getCount(), remarkStore.getCount() <= 1);
            if (remarkStore.getCount() == 1){
                return remarkStore.getAt(0);
            }
        }
    },

    getDefaultValues: function(){
        var rec = this.getRemarksRec();
        if (rec){
            return {
                Id: rec.get('Id'),
                date:rec.get('date'),
                project:rec.get('project')

            }
        }

        return null;
    }


});