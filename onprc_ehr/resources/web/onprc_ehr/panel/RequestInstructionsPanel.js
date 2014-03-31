Ext4.define('ONPRC_EHR.panel.RequestInstructionsPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc-requestinstructionpanel',

    initComponent: function(){
        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: [{
                html: 'This form allows you to request ONPRC services, similar to the previous email form.  Use the sections below to fill out the requested services.',
                style: 'padding: 5px;'
            }]
        });

        this.callParent(arguments);
    }
});