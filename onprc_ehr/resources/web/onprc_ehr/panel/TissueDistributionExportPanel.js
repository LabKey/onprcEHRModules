/*
 * Copyright (c) 2017-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Added: 12-16-2021  R.Blasa
Ext4.define('ONPRC_EHR.panel.TissueDistributionExportPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.onprc_ehr-TissueDistributionExportpanel',

    initComponent: function(){
       var  ctx = EHR.Utils.getEHRContext();
        Ext4.apply(this, {
            defaults: {
                border: false
            },
            items: [{
                html: 'This form allows you to export a Tissue Distribution template into an Excel spreadsheet by clicking the link below. Please enter a monkey id into the "Animal ID" input box, and click "View Report" button ' +
                        'located to the upper right section of the reporting screen. ' +
                        ' <br>  After the program has completed generating the report, please select the icon ' +
                        'to the left of the printer icon, and then choose Excel menu to export into an Excel file.  <p>' ,

                style: 'padding: 5px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '<li>View Tissue Distribution Export Template</li>',
                href: ctx['SSRSServerURL'] +'%2fPrime+Reports%2fNecropsy%20Reports%2fTissueDistributionTemplates&rs:Command=Render'
            }]
        });

        this.callParent(arguments);
    }
});