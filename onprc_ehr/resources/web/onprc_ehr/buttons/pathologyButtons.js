EHR.DataEntryUtils.registerDataEntryFormButton('ENTERDEATH', {
    text: 'Enter Death',
    name: 'enterdeath',
    itemId: 'enterdeath',
    tooltip: 'Click to enter the death record for this animal',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in ENTERDEATH button', panel);

        var store = panel.storeCollection.getClientStoreByName('encounters');
        LDK.Assert.assertNotEmpty('Unable to find encounters store in ENTERDEATH button', store);
        LDK.Assert.assertEquality('Did not find a single record in encounters store in ENTERDEATH button.', 1, store.getCount());

        if (!store || store.getCount() != 1){
            Ext4.Msg.alert('Error', 'Unable to find animal ID.  Please contact your administrator');
            return;
        }

        var animalId = store.getAt(0).get('Id');
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

            if (ar.getDeathInfo()){
                Ext4.Msg.alert('Error', 'This animal has already been marked as dead');
                return;
            }
            else {
                Ext4.create('EHR.window.ManageRecordWindow', {
                    schemaName: 'study',
                    queryName: 'deaths',
                    pkCol: 'objectid',
                    pkValue: LABKEY.Utils.generateUUID()
                }).show();
            }
        }, this);
    }
});