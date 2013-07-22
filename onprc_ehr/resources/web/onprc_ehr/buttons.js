LABKEY.ExtAdapter.ns('ONPRC_EHR');

ONPRC_EHR.Buttons = new function(){

    return {
        showManageCases: function(dataRegionName){
            Ext4.create('EHR.panel.ManageCasesWindow', {
                dataRegionName: dataRegionName
            }).show();
        }
    }
};