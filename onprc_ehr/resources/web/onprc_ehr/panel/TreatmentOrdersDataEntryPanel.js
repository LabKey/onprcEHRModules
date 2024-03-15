/* Created: 3-12-2024 by Kollil and Raymond
This script is added to create a pop-up message box when a MPA injection is selected in the medication order form.
Refer to the ticket #9669
*/
Ext4.define('ONPRC_EHR.panel.TreatmentOrdersDataEntryPanel', {
    extend: 'EHR.panel.TaskDataEntryPanel',

    onBeforeSubmit: function(btn){
        if (!btn || !btn.targetQC || ['Completed'].indexOf(btn.targetQC) == -1){
            return;
        }
        var store = this.storeCollection.getClientStoreByName('Treatment Orders');
        LDK.Assert.assertNotEmpty('Unable to find Treatment Orders store', store);

        var ids = [];
        store.each(function(r){
            if (r.get('Id')&& r.get('code')=='E-85760' && r.get('category') == 'Clinical' )
                ids.push(r.get('Id'))
        }, this);
        ids = Ext4.unique(ids);

        if (!ids.length)
            return;

        if (ids.length){
            Ext4.Msg.confirm('Medication Question', 'Have you confirmed start date on CMU Calendar?', function(val){
                if (val == 'yes'){
                    this.onSubmit(btn, true);
                }
                else {

                }
            }, this);
        }
        else {
            this.onSubmit(btn, true);
        }
        return false;
    }
});
