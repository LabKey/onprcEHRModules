/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.ChangeBloodStatusWindow', {
    extend: 'EHR.window.ChangeRequestStatusWindow',

    allowBlankQCState: true,

    getFormItems: function(){
        var items = this.callParent();
        items.push({
            xtype: 'combo',
            name: 'chargetype',
            fieldLabel: 'Assigned To',
            width: this.fieldWidth,
            store: {
                type: 'labkey-store',
                schemaName: 'ehr_lookups',
                queryName: 'bloodChargeType',
                autoLoad: true
            },
            displayField: 'value',
            valueField: 'value'
        });

        return items;
    }
});