Ext4.define('ONPRC_EHR.panel.ServiceRequestsPanel', {
    extend: 'EHR.panel.ServiceRequestsPanel',

    initComponent: function(){
        this.items = this.getItems();

        this.callParent();
    },

    getQueueSections: function(){
        return [{
            //header: 'Requests',
            renderer: function(item){
                return {
                    layout: 'hbox',
                    bodyStyle: 'padding: 2px;background-color: transparent;',
                    defaults: {
                        border: false,
                        bodyStyle: 'background-color: transparent;'
                    },
                    items: [{
                        html: item.name + ':',
                        width: 150
                    },{
                        xtype: 'ldk-linkbutton',
                        text: 'Pending Requests',
                        linkCls: 'labkey-text-link',
                        href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {
                            schemaName: item.schemaName || 'study',
                            'query.queryName': item.queryName,
                            'query.viewName': item.viewName,
                            'query.QCState/Label~eq': 'Request: Pending'
                        })
                    },{
                        xtype: 'ldk-linkbutton',
                        text: 'Approved Requests',
                        linkCls: 'labkey-text-link',
                        style: 'padding-left: 5px;',
                        href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {
                            schemaName: item.schemaName || 'study',
                            'query.queryName': item.queryName,
                            'query.viewName': item.viewName,
                            'query.QCState/Label~eq': 'Request: Approved'
                        })
                    },{
                        xtype: 'ldk-linkbutton',
                        text: 'All Requests',
                        linkCls: 'labkey-text-link',
                        href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {
                            schemaName: item.schemaName || 'study',
                            'query.queryName': item.queryName,
                            'query.viewName': item.viewName,
                            'query.QCState/Label~startswith': 'Request'
                        })
                    }]
                }
            },
            items: [{
                name: 'Pathology Service Request',
                schemaName: 'ehr',
                queryName: 'requests'
            }]
        }];
    }
});