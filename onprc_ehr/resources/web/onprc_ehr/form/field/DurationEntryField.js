/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.form.field.DurationEntryField', {
    extend: 'Ext.form.field.Trigger',
    alias: 'widget.onprc_ehr-durationentryfield',

    triggerCls: 'x4-form-search-trigger',
    triggerToolTip: 'Click to set this to match the current cage',

    initComponent: function(){
        this.callParent(arguments);
    },

    onTriggerClick: function(e){
        var rec = EHR.DataEntryUtils.getBoundRecord(this);
        var interval = '';
        if (rec){
            var d2 = Ext4.Date.clearTime(new Date(), true);
            var d1 = Ext4.Date.clearTime(rec.get('date'), true);
            interval = Ext4.Date.getElapsed(d1, d2);
            interval = interval / (1000 * 60 * 60 * 24);
            interval = Math.floor(interval);

            if (interval)
                this.setValue(interval);
        }
    }
});