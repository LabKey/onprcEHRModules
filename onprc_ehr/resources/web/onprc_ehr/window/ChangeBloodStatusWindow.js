Ext4.define('ONPRC_EHR.window.ChangeBloodStatusWindow', {
    extend: 'EHR.window.ChangeRequestStatusWindow',

    allowBlankQCState: true,

    getFormItems: function(){
        var items = this.callParent();
        items.push({
            xtype: 'combo',
            name: 'chargetype',
            fieldLabel: 'Charge Type',
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