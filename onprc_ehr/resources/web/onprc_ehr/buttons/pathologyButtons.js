/*
 * Copyright (c) 2013 LabKey Corporation
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
                pkValue: objectid || LABKEY.Utils.generateUUID(),
                extraMetaData: {
                    Id: {
                        defaultValue: animalId,
                        editable: false
                    },
                    caseno: {
                        defaultValue: caseno
                    },
                    parentid: {
                        defaultValue: parentid
                    }
                }
            }).show();
        }, this);
    }
});