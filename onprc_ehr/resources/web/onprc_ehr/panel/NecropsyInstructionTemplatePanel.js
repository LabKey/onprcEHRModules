/*
 * Copyright (c) 2017-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Added: 12-16-2021  R.Blasa
Ext4.define('ONPRC_EHR.panel.NecropsyInstructionTemplatePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc_ehr-NecropsyInstructionTemplatePanel',

    initComponent: function(){
        var  ctx = EHR.Utils.getEHRContext();
        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: [{
                html: 'This form allows you to generate a Necropsy template report with an option to save report into various file formats. PLease click the link below, and enter a monkey id into <br>  the "Animal ID", or Case number into the input box, and click "View Report" button ' +
                        'located on the upper right section of the reporting screen. ' +
                        '  After the program <br>  has completed generating the report, please select the icon ' +
                        'to the left of the printer icon, and choose to save a report, or print it.  <p>' ,

                style: 'padding: 5px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '<li><b>View Necropsy Report Template</li>',
                href: ctx['SSRSServerURL'] +'%2fPrime+Reports%2fNecropsy%20Reports%2fNecropsyReportTemplate_Condensed&rs:Command=Render'
            },{
                style: 'padding: 10px;',
                html: ''
            }]
        });

        this.callParent(arguments);
    }
});