/*
 * Copyright (c) 2014-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.NewAnimalDataEntryPanel', {
    extend: 'EHR.panel.TaskDataEntryPanel',
    alias: 'widget.onprc-newanimaldataentrypanel',

    onStoreCollectionCommitComplete: function(sc, extraContext){
        if (Ext4.Msg.isVisible())
            Ext4.Msg.hide();

        var lockPanel = this.down('onprc-lockanimalspanel');
        LDK.Assert.assertNotEmpty('Unable to find lockanimalspanel', lockPanel);

        if (lockPanel){
            var isLocked = !lockPanel.down('#lockBtn').locked;
            if (isLocked){
                Ext4.Msg.confirm('Data entry locked', 'Data entry is currently locked.  If you just finished entering the animal Id(s) that locked the form, you probably should unlock it.  However, if someone else locked it you can also leave this alone.  Do you want to unlock the form now?', function(val){
                    if (val == 'yes'){
                        LABKEY.Ajax.request({
                            url: LABKEY.ActionURL.buildURL('onprc_ehr', 'setAnimalLock'),
                            scope: this,
                            failure: LDK.Utils.getErrorCallback(),
                            success: LABKEY.Utils.getCallbackWrapper(function (results) {
                                lockPanel.onSuccess(results);

                                this.superclass.onStoreCollectionCommitComplete.apply(this, [sc, extraContext]);
                            }, this),
                            jsonData: {
                                lock: false
                            }
                        });
                    }
                    else {
                        this.superclass.onStoreCollectionCommitComplete.apply(this, [sc, extraContext]);
                    }
                }, this);
            }
            else {
                this.superclass.onStoreCollectionCommitComplete.apply(this, [sc, extraContext]);
            }
        }
        else {
            this.superclass.onStoreCollectionCommitComplete.apply(this, [sc, extraContext]);
        }
    }
});