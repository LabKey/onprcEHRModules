/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.MarkLabworkDeliveredWindow', {
    extend: 'EHR.window.ChangeRequestStatusWindow',

    allowBlankQCState: true,
    title: 'Mark Samples Delivered',

    getFormItems: function(){
        var qc = EHR.Security.getQCStateByLabel('Request: Sample Delivered');
        LDK.Assert.assertNotEmpty('Unable to find QCState: "Request: Sample Delivered"', qc);

        return [{
            xtype: 'hidden',
            fieldLabel: 'Status',
            value: qc ? qc.RowId : null,
            name: 'qcstate'
        },{
            html: 'You are about to mark these samples as delivered.  Are you sure you want to do this?',
            border: false
        }]
    },

    hasError: function(row, errorMsgs){
        var status = this.callParent(arguments);
        if (!status){
            if (row.getValue('qcstate/label') != 'Request: Approved' && row.getValue('qcstate/label') != 'Request: Pending'){
                errorMsgs.push('This can only be performed on pending or approved requests.  Others will be skipped.');
                return true;
            }

            return false;
        }

        return status;
    }
});