/*
 * Copyright (c) 2014-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created: 8-6-2019  R.Blasa
Ext4.define('ONPRC_EHR.panel.ArrivalDataEntryPanel', {
    extend: 'EHR.panel.TaskDataEntryPanel',
    alias: 'widget.onprc-arrivaldataentrypanel',

    onStoreCollectionCommitComplete: function(sc, extraContext){
        if (Ext4.Msg.isVisible())
            Ext4.Msg.hide();

        //Modified 6-5-2015 Blasa Note: provided a process to evaluate contents of store
        // var store = sc.getClientStoreByName('housing');
        var store = sc.getClientStoreByName('arrival');
        LDK.Assert.assertNotEmpty('Unable to find housing store in HousingDataEntryPanel', store);

        if (extraContext && extraContext.successURL  && store.getCount() > 0){
            Ext4.Msg.confirm('Success', 'Do you want to view the room layout now?  This will allow you to verify and/or change dividers', function(val){
                window.onbeforeunload = Ext4.emptyFn;
                if (val == 'yes'){

                    var rooms = [];
                    store.each(function(r){
                        if (r.get('initialRoom') && rooms.indexOf(r.get('initialRoom')) == -1){
                            rooms.push(r.get('initialRoom'));
                        }
                    }, this);

                    window.location = LABKEY.ActionURL.buildURL('onprc_ehr', 'printRoom', null, {rooms: rooms});
                }
                else {
                    window.location = extraContext.successURL;
                }
            }, this);

            return;
        }

        this.callParent(arguments);
    }
});