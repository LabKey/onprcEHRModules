
//Created: 12-13-2016 R.Blasa
//Modified: 7-17-2017  R.Blasa

Ext4.define('onprc_ehr.panel.EnterDataPanel', {
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
                        schemaName: 'onprc_ehr',
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
            },{
                title: 'Queues',
                bodyStyle: 'margin: 5px;',
                items: [{
                    xtype: 'ldk-navpanel',
                    sections: [{
                        header: 'Reports',
                        renderer: function (item) {
                            return item;
                        },
                        items: [{
                            xtype: 'ldk-linkbutton',
                            text: 'Service Request Summary',
                            linkCls: 'labkey-text-link',
                            href: LABKEY.ActionURL.buildURL('ldk', 'runNotification', null, {key: 'org.labkey.onprc_ehr.notification.RequestAdminNotification'})
                        }]
                    },{
                        header: 'PMIC Service Requests',  //Added by Kolli 3/23/2020
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Pending', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Scheduled Today',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType, 'query.date~dateeq': (new Date()).format('Y-m-d')})
                                }]
                            }
                        },
                        items: [{
                            name: 'Procedure Request',
                            chargeType: 'PMIC'

                        }]
                    },{
                        //header: 'Blood Draw Requests',
                        header: 'ASB Service Requests',
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Blood Draws', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Pending', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Blood Draws', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Scheduled Today',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Blood Draws', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType, 'query.date~dateeq': (new Date()).format('Y-m-d')})
                                }]
                            }
                        },
                        items: [{
                            name: 'Blood Draw Request',      //Modified: 1-7-2017 R.Blasa restored back as ASB Services
                            chargeType: 'DCM: ASB Services'
                        }]
                    },{
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Drug Administration', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Pending', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Drug Administration', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Scheduled Today',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Drug Administration', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType, 'query.date~dateeq': (new Date()).format('Y-m-d')})
                                }]
                            }
                        },
                        items: [{
                            //name: 'ASB Services',
                            name: 'Treatment Given Request',
                            chargeType: 'DCM: ASB Services'

                        }]
                    },{
                        //header: 'Procedure Requests',
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Pending', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Scheduled Today',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType, 'query.date~dateeq': (new Date()).format('Y-m-d')})
                                }]
                            }
                        },
                        items: [{
                            //name: 'ASB Services',
                            name: 'Procedure Request',
                            chargeType: 'DCM: ASB Services'

                        }]
                    },{
                        //header: 'Blood Draw Requests',
                        header: 'Colony Service Requests',
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Blood Draws', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Pending', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Blood Draws', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Scheduled Today',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Blood Draws', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType, 'query.date~dateeq': (new Date()).format('Y-m-d')})
                                }]
                            }
                        },
                        items: [{
                            name: 'Blood Draw Request',      //Modified: 1-7-2017 R.Blasa restored back as ASB Services
                            chargeType: 'DCM: Colony Services'

                        }]
                    },{
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Drug Administration', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Pending', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Drug Administration', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Scheduled Today',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Drug Administration', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType, 'query.date~dateeq': (new Date()).format('Y-m-d')})
                                }]
                            }
                        },
                        items: [{
                            //name: 'ASB Services',
                            name: 'Treatment Given Request',
                            chargeType: 'DCM: Colony Services'

                        }]

                    },{
                        //header: 'Procedure Requests',
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Pending', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType})
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Scheduled Today',
                                    linkCls: 'labkey-text-link',
                                    style: 'padding-left: 5px;',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'encounters', 'query.viewName': 'Requests', 'query.QCState/Label~eq': 'Request: Approved', 'query.chargetype~eq': item.chargeType, 'query.date~dateeq': (new Date()).format('Y-m-d')})
                                }]
                            }
                        },
                        items: [{
                            //name: 'ASB Services',
                            name: 'Procedure Request',
                            chargeType: 'DCM: Colony Services'

                        }]
                    },{
                        header: 'Lab Tests',
                        renderer: function(item){
                            return item;
                        },
                        items: [{
                            layout: 'hbox',
                            bodyStyle: 'padding: 2px;background-color: transparent;',
                            defaults: {
                                border: false
                            },
                            items: [{
                                html: 'Clinpath:',
                                width: 200
                            },{
                                xtype: 'ldk-linkbutton',
                                text: 'Requests With Manual Results',
                                linkCls: 'labkey-text-link',
                                href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Clinpath Runs', 'query.viewName': 'Requests', 'query.QCState/Label~startswith': 'Request:', 'query.servicerequested/chargetype~eq': 'Clinpath', 'query.mergeSyncInfo/automaticresults~eq': false})
                            },{
                                xtype: 'ldk-linkbutton',
                                text: 'Requests With Automatic Results',
                                linkCls: 'labkey-text-link',
                                href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Clinpath Runs', 'query.viewName': 'Requests', 'query.QCState/Label~startswith': 'Request:', 'query.servicerequested/chargetype~eq': 'Clinpath', 'query.mergeSyncInfo/automaticresults~eq': true})
                            }]
                        },{
                            layout: 'hbox',
                            bodyStyle: 'padding: 2px;background-color: transparent;',
                            defaults: {
                                border: false
                            },
                            items: [{
                                html: 'SPF Surveillance:',
                                width: 200
                            },{
                                xtype: 'ldk-linkbutton',
                                text: 'All Requests',
                                linkCls: 'labkey-text-link',
                                href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'Clinpath Runs', 'query.QCState/Label~startswith': 'Request:', 'query.servicerequested/chargetype~eq': 'SPF Surveillance Lab'})
                            }]
                        }]
                    },{

                        //Created: 9-21-2021
                        header: 'Necropsy Request',
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, Ext4.apply({schemaName: 'study', 'query.queryName': 'encounters','query.QCState/Label~eq': 'Request: Pending', 'query.type/value~eq': 'Tissues'}))
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, Ext4.apply({schemaName: 'study', 'query.queryName': 'encounters','query.QCState/Label~eq': 'Request: Approved', 'query.type/value~eq': 'Tissues'}))
                                }]
                            }
                        },
                        items: [{
                            name: 'Necropsy Procedure Request'
                        }]


                    },{
                        header: 'Transfer Requests',
                        renderer: function(item){
                            return {
                                layout: 'hbox',
                                bodyStyle: 'padding: 2px;background-color: transparent;',
                                defaults: {
                                    border: false
                                },
                                items: [{
                                    html: item.name + ':',
                                    width: 200
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Unapproved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, Ext4.apply({schemaName: 'onprc_ehr', 'query.queryName': 'housing_transfer_requests', 'query.viewName': 'Unapproved Requests'}, item.areaFilter))
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Approved Requests',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, Ext4.apply({schemaName: 'onprc_ehr', 'query.queryName': 'housing_transfer_requests', 'query.viewName': 'Approved Requests'}, item.areaFilter))
                                },{
                                    xtype: 'ldk-linkbutton',
                                    text: 'Transfers Today',
                                    linkCls: 'labkey-text-link',
                                    href: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, Ext4.apply({schemaName: 'onprc_ehr', 'query.queryName': 'housing_transfer_requests', 'query.viewName': 'Approved Requests', 'query.date~dateeq': (new Date()).format('Y-m-d')}, item.areaFilter))
                                }]
                            }
                        },
                        items: [{
                            name: 'Corral',
                            chargeType: 'DCM: Colony Services',
                            areaFilter: {
                                'query.room/area~eq': 'Corral'
                            }
                        },{
                            name: 'PENS/Shelters',
                            chargeType: 'DCM: ASB Services',
                            areaFilter: {
                                'query.room/area~in': 'PENS;Shelters'
                            }
                        },{
                            name: 'All Other',
                            areaFilter: {
                                'query.room/area~notin': 'Corral;PENS;Shelters'
                            }
                        }]
                    }]
                }]
            }]
    }
});