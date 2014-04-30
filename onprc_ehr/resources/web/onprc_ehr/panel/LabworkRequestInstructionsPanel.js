Ext4.define('ONPRC_EHR.panel.RequestInstructionsPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc-labworkrequestinstructionspanel',

    initComponent: function(){
        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: [{
                html: 'This form allows you to request Labwork, similar to requesting in Merge.  After requesting Clinpath services through this form, this request will be created in Merge.  You can print print labels through Merge.<p>' +
                '<a class="labkey-text-link" href="http://137.53.5.96:8080/fflexesuite/login.jsp" target="_blank">Click here to open Merge</a>',
                style: 'padding: 5px;'
            }]
        });

        this.callParent(arguments);
    }
});