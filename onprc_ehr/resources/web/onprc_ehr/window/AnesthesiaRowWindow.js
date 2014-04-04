/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.AnesthesiaRowWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            bodyStyle: 'padding: 5px;',
            width: 450,
            title: 'Set Assignment Values',
            items: [{
                html: 'This would allow you to enter one row per animal'
            }],
            buttons: [{
                text: 'Submit',
                scope: this,
                handler: this.onSubmit
            },{
                text: 'Cancel',
                handler: function(btn){
                    btn.up('window').close();
                }
            }]
        });

        this.callParent(arguments);
    },

    onSubmit: function(){

    }
});

EHR.DataEntryUtils.registerGridButton('ADD_ANESTHESIA', function(config){
    config = config || {};

    return Ext4.Object.merge({
        text: 'Add Anesthesia Row',
        handler: function(btn){
            var grid = btn.up('gridpanel');
            LDK.Assert.assertNotEmpty('Unable to find gridpanel in ADD_ANESTHESIA button', grid);

            Ext4.create('ONPRC_EHR.window.AnesthesiaRowWindow', {
                targetStore: grid.store
            }).show();

        }
    }, config);
});