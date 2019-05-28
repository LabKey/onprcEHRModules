/*
 * Copyright (c) 2013-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('onprc_ehr.panel.ApplyFormTemplatePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc-applyformtemplatepanel',

    initComponent: function(){
        var buttons = [];
        LDK.Assert.assertNotEmpty('No data entry panel', this.dataEntryPanel);
        var btnCfg = EHR.DataEntryUtils.getDataEntryFormButton('APPLYFORMTEMPLATE');
        if (btnCfg){
            btnCfg = this.dataEntryPanel.configureButton(btnCfg);
            if (btnCfg){
                btnCfg.defaultDate = new Date();
                btnCfg.text = 'Apply Template To Form';
                buttons.push(btnCfg);
            }
        }



        Ext4.apply(this, {
            defaults: {

            },
            bodyStyle: 'padding: 5px;',
            title: 'Template Tools',
            items: [{
                html: 'Use the \'Apply Form Template\' button to selectively populate the entry grids below.',
                maxWidth: Ext4.getBody().getWidth() * 0.8,
                style: 'padding-top: 10px;padding-bottom: 10px;',
                border: false
            },{
                layout: 'hbox',
                border: false,
                defaults: {
                    style: 'margin-right: 5px;'
                },
                items: buttons
            }]
        });

        this.callParent(arguments);
    }

});