/**
 * Used to display the results of ONPRC.Utils.getNavItems using an IconPanel.
 * @cfg category The category of icons to display
 */
Ext4.define('ONPRC.panel.IconPanel', {
    extend: 'LABKEY.ext.IconPanel',
    initComponent: function(){
        this.store = Ext4.create('Ext.data.Store', {
            proxy: 'memory',
            fields: ['name', 'url', 'iconurl']
        });

        Ext4.apply(this, {
            border: false,
            iconField: 'iconurl',
            labelField: 'name',
            urlField: 'url',
            iconSize: 'large',
            labelPosition: 'bottom'
        });

        ONPRC.Utils.getNavItems({
            scope: this,
            success: function(results){
                if (this.category && results[this.category]){
                    var toAdd = [];
                    Ext4.each(results[this.category], function(result){
                        var rec = LDK.StoreUtils.createModelInstance(this.store, {
                            name: result.name,
                            url: result.canRead ? result.url : null,
                            iconurl: LABKEY.ActionURL.buildURL('project', 'downloadProjectIcon', result.path)
                        });

                        toAdd.push(rec);
                    }, this);

                    if (toAdd.length)
                        this.store.add(toAdd);
                }

            }
        });

        this.callParent();
    }
});