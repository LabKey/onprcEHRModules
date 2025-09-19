/*
 * Copyright (c) 2014-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.ExamInstructionsPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc_ehr-examinstructionspanel',

    initComponent: function(){
        var buttons = [];
        LDK.Assert.assertNotEmpty('No data entry panel', this.dataEntryPanel);
        var btnCfg = EHR.DataEntryUtils.getDataEntryFormButton('APPLYFORMTEMPLATE_NO_ID');
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
            title: 'Instructions',
            items: [{
                html: 'Use the \'Apply Form Template\' button below to load predefined input values ',
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