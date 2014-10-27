/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.AddFemaleAnimalsWindow', {
    extend: 'EHR.window.AddAnimalsWindow',

    initComponent: function(){
        this.callParent(arguments);
    },

    getBaseFilterArray: function(){
        //females only
        return [LABKEY.Filter.create('Id/demographics/gender', 'f', LABKEY.Filter.Types.EQUAL)]
    }
});

EHR.DataEntryUtils.registerGridButton('ADD_FEMALE_ANIMALS', function(config){
    return Ext4.Object.merge({
        text: 'Add Batch',
        tooltip: 'Click to add a batch of animals, either as a list or by location.  This will return females only.',
        handler: function(btn){
            var grid = btn.up('gridpanel');

            Ext4.create('ONPRC_EHR.window.AddFemaleAnimalsWindow', {
                targetStore: grid.store,
                formConfig: grid.formConfig
            }).show();
        }
    }, config);
});