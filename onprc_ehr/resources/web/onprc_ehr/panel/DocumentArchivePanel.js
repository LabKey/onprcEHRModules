/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.DocumentArchivePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc-documentarchivepanel',

    initComponent: function(){
        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: this.getItems()
        });

        this.callParent(arguments);
    },

    getItems: function(){
        var ctx = LABKEY.getModuleContext('onprc_ehr');
        if (ctx && ctx.DocumentArchiveContainer){
            return [{
                html: 'When animals arrive or are shipped from the center, associated documents can be archived.  Use the link below to open this folder and deposit these documents.',
                style: 'padding: 5px;'
            },{
                xtype: 'ldk-linkbutton',
                text: 'Open Document Archive',
                linkTarget: '_blank',
                linkCls: 'labkey-text-link',
                href: LABKEY.ActionURL.buildURL('project', 'start', ctx.DocumentArchiveContainer),
                style: 'margin: 5px;'
            }];
        }
        else {
            return [{
                html: 'The location of the PDF archive has not been set.  Please contact your administrator to configure this.',
                style: 'padding: 5px;'
            }];
        }
    }
});