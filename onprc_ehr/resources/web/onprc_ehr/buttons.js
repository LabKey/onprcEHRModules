/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.ns('ONPRC_EHR');

ONPRC_EHR.Buttons = new function(){

    return {
        showManageCases: function(dataRegionName){
            Ext4.create('EHR.panel.ManageCasesWindow', {
                dataRegionName: dataRegionName
            }).show();
        }
    }
};