/*
 * Copyright (c) 2014-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created to allow a custom row editor plugin and column that summarize observations
 */
Ext4.define('ONPRC_EHR.grid.PairingObservationGridPanel', {
    extend: 'EHR.grid.Panel',
    alias: 'widget.onprc_ehr-pairingbservationgridpanel',

    initComponent: function(){
        this.pairingobservationTypesStore = ONPRC.Utils.getpairingObservationTypesStore();

        this.callParent(arguments);
    },

    getEditingPlugin: function(){
        LDK.Assert.assertNotEmpty('this.pairingobservationTypesStore is null in PairingObservationsGridPanel', this.pairingobservationTypesStore);

        return Ext4.create('ONPRC_EHR.grid.plugin.pairingObservationsCellEditing', {
            pluginId: this.editingPluginId,
            clicksToEdit: this.clicksToEdit,
            pairingobservationTypesStore: ONPRC.Utils.getpairingObservationTypesStore()
        });
    }
});