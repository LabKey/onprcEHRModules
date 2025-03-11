/*
 * Copyright (c) 2014-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext4.define('ONPRC_EHR.window.CopyTaskWindow', {
    extend: 'EHR.window.CopyTaskWindow',

    initComponent: function(){
        this.callParent(arguments);

        this.defaultQCStateLabel = 'In Progress';
    }
});

EHR.DataEntryUtils.registerDataEntryFormButton('COPY_TASKS', {
    text: 'Copy Previous Task',
    name: 'copyFromTask',
    itemId: 'copyFromTask',
    tooltip: 'Click to copy records from a previously created task',
    handler: function(btn){
        var dataEntryPanel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataentrypanel in COPY_TASKS', dataEntryPanel);

        Ext4.create('ONPRC_EHR.window.CopyTaskWindow', {
            dataEntryPanel: dataEntryPanel
        }).show();
    }
});

