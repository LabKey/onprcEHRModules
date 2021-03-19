/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * A trigger field which only allows numeric characters
 */

/*Convert the dosage units from mCi to mBq:
1mCi = 37MBq
By Kollil - 9/25/2020
 */
Ext4.define('EHR.form.field.PMIC_SPECTDoseCalcField', {
    extend: 'EHR.form.field.TriggerNumberField',
    alias: 'widget.ehr-PMIC_SPECTDoseCalcField',

    triggerCls: 'x4-form-search-trigger',

    triggerToolTip: 'Click to calculate the dosage in MBq units',

    initComponent: function(){
        this.callParent(arguments);
    },

    onTriggerClick: function(){
        //Get the current record
        var record = EHR.DataEntryUtils.getBoundRecord(this);
        if (!record){
            return;
        }
        //if empty, throw error
        if (!record.get('SPECTDoseMCI'))  {
            Ext4.Msg.alert('Error', 'Must enter the SPECT Dose (mCi)');
            return;
        }
        //convert the units from Millicurie [mCi] to Megabecquerel [MBq]: 1 Mci = 37 MBq and display the value in the PETDoseMBQ field
        var mBq_units = record.get('SPECTDoseMCI') * 37;
        if (mBq_units)
            record.set('SPECTDoseMBQ', mBq_units);
    }

});