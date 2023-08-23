
var ctx = LABKEY.moduleContext.ehr_compliancedb;
EHR.DataEntryUtils.registerDataEntryFormButton('EMPLOYEERUN', {
    name: 'submit',
    text: 'Submit',
    requiredQC: 'Completed',
    targetQC: 'Completed',
    errorThreshold: 'ERROR',
    successURL: LABKEY.ActionURL.getParameter('returnUrl') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('ONPRC_EHR_ComplianceDB', 'enterData.view',(ctx ? ctx['EmployeeContainer'] : null), null),
    itemId: 'submitBtn',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        Ext4.Msg.confirm('Finalize Form', 'You are about to finalize this form.  Do you want to do this?', function(v){(ctx ? ctx['BillingContainer'] : null), null
            if(v === 'yes')
            {
                this.onSubmit(btn);
                panel.disable();
            }

        }, this);
    },
    disableOn: 'ERROR'
});


EHR.DataEntryUtils.registerDataEntryFormButton('EMPLOYEECLOSE', {
    name: 'closeBtn',
    text: 'Save & Close',
    requiredQC: 'In Progress',
    targetQC: 'In Progress',
    errorThreshold: 'WARN',
    successURL: LABKEY.ActionURL.getParameter('returnUrl') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('ONPRC_EHR_ComplianceDB', 'enterData.view',(ctx ? ctx['EmployeeContainer'] : null), null),
    itemId: 'closeBtn',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        panel.onSubmit(btn);
    },
    disableOn: 'ERROR'
});
