/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @param fieldConfigs
 */
Ext4.define('onprc_ehr.data.PathTissuesClientStore', {
    extend: 'EHR.data.DataEntryClientStore',

    constructor: function(){
        this.callParent(arguments);

        this.on('add', this.revalidate, this);
        this.on('insert', this.revalidate, this);
        this.on('remove', this.revalidate, this);
    },

    revalidate: function(){
        // this method is called when there are changes in the stores on the form and
        // the following call is required to re-validate all the stores to reset row count
        this.storeCollection.validateAll();
    },

    getExtraContext: function() {

        var miscCharges = {};
        var clientStores = this.storeCollection.clientStores.items;
        for (var idx = 0; idx < clientStores.length; idx++) {
            var item = clientStores[idx];
            if (item.storeId.indexOf("miscCharges") > 0) {
                var data = item.data;

                miscCharges['miscChargesEntered'] = data.items.length;
            }
        }

        if (!LABKEY.Utils.isEmptyObj(miscCharges)) {
            miscCharges = Ext4.encode(miscCharges);

            return {
                MiscChargesInTransaction: miscCharges,
                // Tell the trigger scripts it's OK to use a placeholder ID
                AllowAnyId: true
            }
        }
        return null;
    }
});
