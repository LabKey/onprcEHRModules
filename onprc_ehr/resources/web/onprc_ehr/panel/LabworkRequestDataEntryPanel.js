/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.LabworkRequestDataEntryPanel', {
    extend: 'EHR.panel.RequestDataEntryPanel',
    alias: 'widget.onprc-labworkrequestdataentrypanel',

    initComponent: function(){
        this.callParent(arguments);
    },

    onStoreCollectionCommitComplete: function(sc, extraContext){
        if (Ext4.Msg.isVisible())
            Ext4.Msg.hide();

        if (extraContext && extraContext.successURL){
                Ext4.Msg.alert('Message', 'Your Lab Request have been synced into Orchard. Please print your labels by accessing the Orchard app located on your Windows desktop. If you need an Orchard Login, please email the ONPRC Clin Path Lab at ONPRCClinPathLab@ohsu.edu.' +
                        (!Ext4.isIE ? '  Note: There may be a delay of about ten minutes before you are able to print your labels through the Orchard application.' : ''), function(val){
                    window.onbeforeunload = Ext4.emptyFn;
                    window.location = extraContext.successURL;

                }, this);
                return;
            }
        }

});