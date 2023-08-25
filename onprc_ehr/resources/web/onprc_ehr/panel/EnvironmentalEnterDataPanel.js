
//Created: 11-10-2021


Ext4.define('ehr_compliancedb.panel.EnvironmentalEnterDataPanel', {
    extend: 'LABKEY.ext4.BootstrapTabPanel',
    autoHeight: true,
    layout: 'anchor',

    initComponent: function(){
        Ext4.apply(this, {
            items: this.getItems()
        });

        this.loadData();

        this.callParent();
    },

    loadData: function(){
        EHR.Utils.getDataEntryItems({
            includeFormElements: false,
            scope: this,
            success: this.onLoad
        });
    },

    onLoad: function(results){
        var formMap = {};
        Ext4.each(results.forms, function(form){
            if (form.isAvailable && form.isVisible && form.canInsert){
                formMap[form.category] = formMap[form.category] || [];
                formMap[form.category].push({
                    name: form.label,
                    url: LABKEY.ActionURL.buildURL('ehr', 'dataEntryForm', null, {formType: form.name})
                });
            }
        }, this);

        var sectionNames = Ext4.Object.getKeys(formMap);
        sectionNames = sectionNames.sort();

        var sections = [];
        Ext4.Array.forEach(sectionNames, function(section){
            var items = formMap[section];
            items = LDK.Utils.sortByProperty(items, 'name', false);
            sections.push({
                header: section,
                items: items
            });
        }, this);

        var tab = Ext4.ComponentQuery.query("#enterNew")[0];
        tab.removeAll();
        tab.add({
            xtype: 'ldk-navpanel',
            sections: sections
        });
    },

    onSuccessResize: function (dr){
        var width1 = Ext4.get(dr.domId).getSize().width + 50;
        var width2 = Ext4.get(this.id).getSize().width;

        if(width1 > width2){
            console.log(width1+'/'+width2)
            this.setWidth(width1);
            console.log('resizing')
        }
        else {
            this.setWidth('100%');
        }
    },


    getItems: function(){
        return [
            {
                title: 'Enter New Data',
                ref: 'EnterNewData',
                items: [{
                    xtype: 'panel',
                    bodyStyle: 'margin: 5px; padding-top: 10px;',
                    itemId: 'enterNew',
                    id: 'enterNew',
                    defaults: {
                        border: false
                    },
                    items: [{
                        html: 'Loading...'
                    }]
                }]
            },
            {
                title: 'My Tasks',
                bodyStyle: 'padding-top: 10px;',
                ref: 'MyTasks',
                items: [{
                    itemId: 'MyTasks',
                    xtype: 'ldk-querycmp',
                    cls: 'my-tasks-marker',
                    queryConfig: {
                        schemaName: 'ehr',
                        queryName: 'my_tasks',
                        viewName: 'Active Tasks',
                        scope: this,
                        success: this.onSuccessResize
                    }
                }]
            },{
                title: 'All Tasks',
                ref: 'AllTasks',
                bodyStyle: 'padding-top: 10px;',
                items: [{
                    itemId: 'AllTasks',
                    xtype: 'ldk-querycmp',
                    cls: 'all-tasks-marker',
                    queryConfig: {
                        schemaName: 'ehr',
                        queryName: 'tasks',
                        viewName: 'Active Tasks',
                        scope: this,
                        success: this.onSuccessResize
                    }

                }]
            }]
    }
});