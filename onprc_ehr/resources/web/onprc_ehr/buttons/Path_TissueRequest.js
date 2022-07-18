
//Created: 7-18-2022  R.Blasa

EHR.DataEntryUtils.registerDataEntryFormButton('PATH_REQUEST', {
    text: 'Request',
    name: 'request',
    targetQC: 'Request: Pending',
    requiredQC: 'Request: Pending',
    errorThreshold: 'WARN',
    successURL: LABKEY.ActionURL.getParameter('srcURL') || LABKEY.ActionURL.getParameter('returnUrl') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('ehr', 'enterData.view'),
    disabled: true,
    itemId: 'requestBtn',
    handler: function (btn) {
        var panel = btn.up('ehr-dataentrypanel');
        panel.onSubmit(btn);
    },
    disableOn: 'WARN'

});




