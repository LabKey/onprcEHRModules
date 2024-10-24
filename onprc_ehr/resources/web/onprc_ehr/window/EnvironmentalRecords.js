
var ctx = LABKEY.moduleContext.onprc_ehr;
EHR.DataEntryUtils.registerDataEntryFormButton('ENV_RUN', {
        name: 'submit',
        text: 'Submit',
        requiredQC: 'Completed',
        targetQC: 'Completed',
        errorThreshold: 'ERROR',
        // successURL: LABKEY.ActionURL.getParameter('returnUrl') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('ONPRC_EHR', 'EnvironmentalenterData.view',(ctx ? ctx['EHRStudyContainer'] : null), null),
    successURL: LABKEY.ActionURL.getParameter('srcURL') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('onprc_ehr', 'EnvironmentalenterData.view'),
        itemId: 'submitBtn',
        handler: function(btn){
            var panel = btn.up('ehr-dataentrypanel');
            Ext4.Msg.confirm('Finalize Form', 'You are about to finalize this form.  Do you want to do this?', function(v){(ctx ? ctx['onprc_ehrContainer'] : null), null
                if(v === 'yes')
                {
                    this.onSubmit(btn);
                    panel.disable();
                }

            }, this);
        },
        disableOn: 'ERROR'
    });


EHR.DataEntryUtils.registerDataEntryFormButton('ENV_CLOSE', {
    name: 'closeBtn',
    text: 'Save & Close',
    requiredQC: 'In Progress',
    targetQC: 'In Progress',
    errorThreshold: 'WARN',
    // successURL: LABKEY.ActionURL.getParameter('returnUrl') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('ONPRC_EHR', 'EnvironmentalenterData.view',(ctx ? ctx['EHRStudyContainer'] : null), null),
    successURL: LABKEY.ActionURL.getParameter('returnUrl') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('onprc_ehr', 'EnvironmentalenterData.view'),
    itemId: 'closeBtn',
        handler: function(btn){
            var panel = btn.up('ehr-dataentrypanel');
            panel.onSubmit(btn);
        },
        disableOn: 'ERROR'
    });
