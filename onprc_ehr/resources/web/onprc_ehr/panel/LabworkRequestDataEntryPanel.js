Ext4.define('ONPRC_EHR.panel.LabworkRequestDataEntryPanel', {
    extend: 'EHR.panel.RequestDataEntryPanel',
    alias: 'widget.onprc-labworkrequestdataentrypanel',

    initComponent: function(){
        var mergeURL = LABKEY.getModuleProperty('MergeSync', 'MergeURL');

        this.callParent(arguments);
    },

    onStoreCollectionCommitComplete: function(sc, extraContext){
        if (Ext4.Msg.isVisible())
            Ext4.Msg.hide();

        if (extraContext && extraContext.successURL){
            var mergeURL = LABKEY.getModuleProperty('MergeSync', 'MergeURL');
            if (mergeURL){
                Ext4.Msg.confirm('Success', 'The requests have been synced to merge.  Do you want to open merge now?', function(val){
                    window.onbeforeunload = Ext4.emptyFn;
                    if (val == 'yes'){
                        window.location = mergeURL;
                    }
                    else {
                        window.location = extraContext.successURL;
                    }
                }, this);

                return;
            }
        }

        this.callParent(arguments);
    }
});