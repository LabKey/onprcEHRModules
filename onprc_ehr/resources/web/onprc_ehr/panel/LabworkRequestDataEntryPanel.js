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
            Ext4.Msg.alert('Message', 'The Lab Requests have been synced into Orchard.  ' +
                    '<b>Clin Path orders in Prime can only be done ahead of time and no later than 4pm on the business day prior to when the samples are submitted to Clin Path. Labels will ' +
                    'not be available to print from Orchard until the next business day after the orders are placed. If same day orders are needed, please place these orders in Orchard. </b>' +
                    'If you have questions, please contact the Clin Path Lab at 503-346-5297. Please print your labels by accessing the Orchard app located' +
                    ' on your Windows desktop. ' +
                    (!Ext4.isIE ? 'If you need an Orchard Login, please email the ONPRC Clin Path Lab at ONPRCClinPathLab@ohsu.edu.  Thank you.' : ''), function(val){
                window.onbeforeunload = Ext4.emptyFn;
                window.location = extraContext.successURL;

                }, this);
                return;
            }
        }

});