Ext4.ns('ONPRC.Billing');

ONPRC.Billing.buttons = new function(){


    return {
        cacheChargesHandler: function(dataRegionName, btn){
            Ext4.Msg.confirm('Save Charges?', 'The selected charges will be saved as the official record for this period.  Continue?', function(){

            });
        },

        reverseChangesHandler: function(dataRegionName, btn){
            Ext4.Msg.confirm('Reverse Charges?', 'The selected charges will be reversed, with a credit placed on the currect account.  Continue?', function(){

            });
        }
    }
}