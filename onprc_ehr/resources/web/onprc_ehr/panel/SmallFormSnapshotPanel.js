/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created:7-12-2016 R.Blasa
Ext4.define('onprc_ehr.panel.SmallFormSnapshotPanel', {
    extend: 'onprc_ehr.panel.SnapshotPanel',            //Modiied 8-24-2016 R.Blasa
    alias: 'widget.onprc_ehr-smallformsnapshotpanel',

    showLocationDuration: false,
    showActionsButton: false,

    initComponent: function(){

        this.defaultLabelWidth = 120;
        this.callParent();
    },

    getItems: function(){
        var items = this.getBaseItems();

        if (!this.redacted){
            items[0].items.push({
                name: 'treatments',
                xtype: 'ehr-snapshotchildpanel',     //Modified 8-24-2016 R.blasa
                headerLabel: 'Current Medications / Prescribed Diets',
                emptyText: 'There are no active medications'
            });
        }

        return items;
    }
});