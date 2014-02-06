/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Used to display the results of ONPRC.Utils.getNavItems using an IconPanel.
 * @cfg category The category of icons to display
 */
Ext4.define('ONPRC.panel.IconPanel', {
    extend: 'LABKEY.ext.IconPanel',
    initComponent: function(){
        Ext4.QuickTips.init();
        this.store = Ext4.create('Ext.data.Store', {
            proxy: 'memory',
            fields: ['name', 'url', 'iconurl', 'tooltip']
        });

        Ext4.apply(this, {
            border: false,
            iconField: 'iconurl',
            labelField: 'name',
            urlField: 'url',
            iconSize: 'large',
            tooltipField: 'tooltip',
            labelPosition: 'bottom'
        });

        ONPRC.Utils.getNavItems({
            scope: this,
            success: function(results){
                if (this.category && results[this.category]){
                    var toAdd = [];
                    Ext4.each(results[this.category], function(result){
                        var url = result.publicContainer ? (result.publicContainer.canRead ? result.publicContainer.url : null) : (result.canRead ? result.url : null);
                        var canRead = result.publicContainer ? result.publicContainer.canRead : result.canRead;

                        var rec = LDK.StoreUtils.createModelInstance(this.store, {
                            name: result.name,
                            url: url,
                            tooltip: !canRead ? 'You do not have permission to view this page' : null,
                            iconurl: LABKEY.ActionURL.buildURL('project', 'downloadProjectIcon')
                        });

                        toAdd.push(rec);
                    }, this);

                    if (toAdd.length)
                        this.store.add(toAdd);
                }

            }
        });

        this.callParent();
    }
});