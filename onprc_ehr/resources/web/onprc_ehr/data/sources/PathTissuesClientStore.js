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

        this.on('update', this.onRecordUpdate, this);
    },

    onRecordUpdate: function(store, record){
        // this method is called when there are changes in the stores on the form and
        // the following call is required to re-validate all the stores to reset the bactiCodeInTransaction
        this.storeCollection.validateAll();
    },

    getExtraContext: function() {

        var TissueCodes = {};
        var clientStores = this.storeCollection.clientStores.items;
        for (var idx = 0; idx < clientStores.length; idx++) {
            var item = clientStores[idx];
            if (item.storeId.indexOf("miscCharges") > 0) {
                var data = item.data;

                TissueCodes['TissueCodesEntered'] = data.items.length !== 0;
            }
        }

        if (!LABKEY.Utils.isEmptyObj(TissueCodes)) {
            TissueCodes = Ext4.encode(TissueCodes);

            return {
                TissueCodeInTransaction: TissueCodes
            }
        }
        return null;
    }
});
