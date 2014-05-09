Ext4.define('ONPRC_EHR.panel.HousingDataEntryPanel', {
    extend: 'EHR.panel.TaskDataEntryPanel',
    alias: 'widget.onprc-housingdataentrypanel',

    onStoreCollectionCommitComplete: function(sc, extraContext){
        if (Ext4.Msg.isVisible())
            Ext4.Msg.hide();

        if (extraContext && extraContext.successURL){
            Ext4.Msg.confirm('Success', 'Do you want to view to room layout now?  This will allow you to verify and/or change dividers', function(val){
                window.onbeforeunload = Ext4.emptyFn;
                if (val == 'yes'){
                    var store = sc.getClientStoreByName('housing');
                    LDK.Assert.assertNotEmpty('Unable to find housing store in HousingDataEntryPanel', store);
                    var rooms = [];
                    store.each(function(r){
                        if (r.get('room') && rooms.indexOf(r.get('room')) == -1){
                            rooms.push(r.get('room'));
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