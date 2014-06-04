/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.RequestInstructionsPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc-labworkrequestinstructionspanel',

    initComponent: function(){
        var mergeURL = LABKEY.getModuleProperty('MergeSync', 'MergeURL');
        var items;
        if (mergeURL){
            items = [{
                html: 'This form allows you to request Labwork, similar to requesting in Merge.  After requesting Clinpath services through this form, this request will be created in Merge.  You can print print labels through Merge.<p>' +
                        '<a class="labkey-text-link" href="' + mergeURL + '" target="_blank">Click here to open Merge</a><p>' +
                        '<a class="labkey-text-link" href="https://bridge.ohsu.edu/research/onprc/dcm/cpu/Shared%20Documents/How%20to%20reprint%20a%20label%20from%20the%20Merge%20LIS.pdf" target="_blank">Click here for instructions on Merge label printing</a>',
                style: 'padding: 5px;'
            }]
        }
        else {
            items = [{
                html: 'The Merge URL has not been configured for this site',
                style: 'padding: 5px;'
            }]
        }

        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: items
        });

        this.callParent(arguments);
    }
});