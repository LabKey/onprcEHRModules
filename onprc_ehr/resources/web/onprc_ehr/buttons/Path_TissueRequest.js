
//Created: 7-18-2022  R.Blasa

EHR.DataEntryUtils.registerDataEntryFormButton('PATH_SAVEDRAFT', {

    SAVEDRAFT: {
        text: 'Save Draft',
        name: 'saveDraft',
        requiredQC: 'Request: Pending',
        errorThreshold: 'WARN',
        disabled: true,
        itemId: 'saveDraftBtn',
        handler: function(btn){
            var panel = btn.up('ehr-dataentrypanel');
            panel.onSubmit(btn, false, true);
        },
        disableOn: 'ERROR'
    },

});




