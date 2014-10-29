Ext4.define('ONPRC_EHR.grid.DragDropGridPanel', {
    extend: 'EHR.grid.Panel',
    alias: 'widget.onprc_ehr-dragdropgridpanel',

    initComponent: function(){
        this.allowDragDropReorder = true;

        this.callParent();
    }
});