/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.grid.DragDropGridPanel', {
    extend: 'EHR.grid.Panel',
    alias: 'widget.onprc_ehr-dragdropgridpanel',

    initComponent: function(){
        this.allowDragDropReorder = true;

        this.callParent();
    }
});