/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg {String} animalId
 * @cfg {String} dataRegionName
 */
//Added: 6-10-2016 R.Blasa
Ext4.define('onprc_ehr.window.ManageTreatmentsWindow', {
    extend: 'Ext.window.Window',

    width: 1290,
    minHeight: 50,

    initComponent: function(){
        Ext4.apply(this, {
            title: 'Manage Treatments: ' + this.animalId,
            modal: true,
            closeAction: 'destroy',
            items: [{
                xtype: 'onprc_ehr-managetreatmentspanel',
                animalId: this.animalId,
                hideButtons: true
            }],
            buttons: this.getButtonConfig()
        });

        this.callParent(arguments);
    },

    getButtonConfig: function(){
        var buttons = onprc_ehr.panel.ManageTreatmentsPanel.getOrderTreatmentButtonConfig(this);
        buttons.push({
            text: 'Close',
            handler: function(btn){
                btn.up('window').close();
            }
        });

        return buttons;
    }
});
