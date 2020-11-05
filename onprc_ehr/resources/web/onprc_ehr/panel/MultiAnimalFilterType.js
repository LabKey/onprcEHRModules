/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Created: 11-15-2017  R.Blasa


Ext4.define('EHR.panel.MultiAnimalFilterType', {
    extend: 'LDK.panel.MultiSubjectFilterType',
    alias: 'widget.onprc_ehr-multianimalfiltertype',

    statics: {
        filterName: 'multiSubject',
        label: 'Multiple Animals'
    },

    getItems: function(){
        var ctx = this.filterContext || {};

        var toAdd = this.callParent();
        var items = [{
            layout: 'hbox',
            border: false,
            defaults: {
                border: false
            },
            items: toAdd
        }]

        items.push({
            xtype: 'ldk-linkbutton',
            text: '[Search By Room/Cage]',
            minWidth: 80,
            style: 'padding-left:200px;',
            handler: function(btn){
                var panel = btn.up('onprc_ehr-multianimalfiltertype');

                Ext4.create('Ext.window.Window', {
                    modal: true,
                    width: 330,
                    closeAction: 'destroy',
                    title: 'Search By Room/Cage',
                    items: [{
                        xtype: 'form',
                        bodyStyle:'padding:5px',
                        items: [{
                            xtype: 'ehr-roomfield',
                            itemId: 'room',
                            name: 'roomField',
                            multiSelect: false,
                            showOccupiedOnly: true,
                            width: 300
                        },{
                            xtype: 'ehr-cagefield',
                            fieldLabel: 'Cage',
                            name: 'cageField',
                            itemId: 'cage',
                            width: 300
                        }]
                    }],
                    buttons: [{
                        text:'Submit',
                        disabled:false,
                        itemId: 'submit',
                        scope: panel,
                        handler: panel.loadRoom
                    },{
                        text: 'Close',
                        handler: function(btn){
                            btn.up('window').hide();
                        }
                    }]
                }).show(btn);
            }
        });

        items.push({
            xtype: 'ldk-linkbutton',
            text: '[Search By Project/Protocol]',
            minWidth: 80,
            handler: function(btn){
                var panel = btn.up('onprc_ehr-multianimalfiltertype');

                Ext4.create('Ext.window.Window', {
                    modal: true,
                    width: 330,
                    closeAction: 'destroy',
                    title: 'Search By Project/Protocol',
                    items: [{
                        xtype: 'form',
                        bodyStyle:'padding:5px',
                        items: [{
                            xtype: 'ehr-projectfield',
                            itemId: 'project',
                            onlyIncludeProjectsWithAssignments: true
                        },{
                            xtype: 'ehr-protocolfield',
                            itemId: 'protocol',
                            onlyIncludeProtocolsWithAssignments: true
                        }]
                    }],
                    buttons: [{
                        text:'Submit',
                        disabled:false,
                        itemId: 'submit',
                        scope: panel,
                        handler: panel.loadProject
                    },{
                        text: 'Close',
                        handler: function(btn){
                            btn.up('window').close();
                        }
                    }]
                }).show(btn);
            },
            style: 'margin-bottom:10px;padding-left:200px;'
        });
        //Added: 11-15-2017  R.Blasa
        items.push({
            xtype: 'ldk-linkbutton',
            text: '[Search By Animal Groups]',
            minWidth: 80,
            handler: function(btn){
                var panel = btn.up('onprc_ehr-multianimalfiltertype');

                Ext4.create('Ext.window.Window', {
                    modal: true,
                    width: 300,
                    height:100,
                    closeAction: 'destroy',
                    title: 'Search By Animal Groups',
                    items: [{
                        xtype: 'labkey-combo',
                        fieldLabel: '<br>Animal Groups<br>',
                        itemId: 'animalGroup',
                        displayField: 'name',
                        valueField: 'rowid',
                        store: {
                            type: 'labkey-store',
                            containerPath: ctx['EHRStudyContainer'],
                            schemaName: 'ehr',
                            queryName: 'animal_groups',
                            viewName: 'Active Groups',
                            columns: 'name, rowid',
                            filterArray: [LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK)],
                            autoLoad: true
                        }
                    }],
                    buttons: [{
                        text:'Submit',
                        disabled:false,
                        itemId: 'submit',
                        scope: panel,
                        handler: panel.loadGroups
                    },{
                        text: 'Close',
                        handler: function(btn){
                            btn.up('window').close();
                        }
                    }]
                }).show(btn);
            },
            style: 'margin-bottom:10px;padding-left:200px;'
        });



        return [{
            xtype: 'panel',
            width: 500,
            border: false,
            defaults: {
                border: false
            },
            items: items
        }];
    },

    loadProject: function(btn){
        var win = btn.up('window');
        var project = win.down('#project').getValue();
        var protocol = win.down('#protocol').getValue();
        win.down('#project').reset();
        win.down('#protocol').reset();

        win.close();

        Ext4.Msg.wait("Loading..");

        if(!project && !protocol){
            Ext4.Msg.hide();
            return;
        }

        var filters = [];

        if(project){
            filters.push(LABKEY.Filter.create('project', project, LABKEY.Filter.Types.EQUAL))
        }

        if(protocol){
            protocol = protocol.toLowerCase();
            filters.push(LABKEY.Filter.create('project/protocol', protocol, LABKEY.Filter.Types.EQUAL))
        }

        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'Assignment',
            viewName: 'Active Assignments',
            sort: 'Id',
            filterArray: filters,
            scope: this,
            success: function(rows){
                var subjectArray = [];
                Ext4.each(rows.rows, function(r){
                    subjectArray.push(r.Id);
                }, this);
                subjectArray = Ext4.unique(subjectArray);
                if(subjectArray.length){
                    this.tabbedReportPanel.setSubjGrid(true, false, subjectArray);
                }
                Ext4.Msg.hide();
            },
            failure: LDK.Utils.getErrorCallback()
        });
    },

    loadGroups: function(btn){
        var win = btn.up('window');
        var groups = win.down('#animalGroup').getValue();
        win.down('#animalGroup').reset();

        win.close();

        Ext4.Msg.wait("Loading..");

        if(!groups){
            Ext4.Msg.hide();
            return;
        }

        var filters = [];

        if(groups){
            filters.push(LABKEY.Filter.create('groupId/rowid', groups, LABKEY.Filter.Types.EQUAL));
            filters.push(LABKEY.Filter.create('enddate',  null, LABKEY.Filter.Types.ISBLANK))
        }


        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'animal_group_members',
            //viewName: 'Active Assignments',
            sort: 'Id',
            filterArray: filters,
            scope: this,
            success: function(rows){
                var subjectArray = [];
                Ext4.each(rows.rows, function(r){
                    subjectArray.push(r.Id);
                }, this);
                subjectArray = Ext4.unique(subjectArray);
                if(subjectArray.length){
                    this.tabbedReportPanel.setSubjGrid(true, false, subjectArray);
                }
                Ext4.Msg.hide();
            },
            failure: LDK.Utils.getErrorCallback()
        });
    },

    loadRoom: function(btn){
        var housingWin = btn.up('window');
        var room = housingWin.down('#room').getValue();
        var cage = housingWin.down('#cage').getValue();
        housingWin.down('#room').reset();
        housingWin.down('#cage').reset();

        housingWin.close();

        Ext4.Msg.wait("Loading...");

        if(!room && !cage){
            Ext4.Msg.hide();
            return;
        }

        var filters = [];

        if(room){
            room = room.toLowerCase();
            filters.push(LABKEY.Filter.create('room', room, LABKEY.Filter.Types.STARTS_WITH))
        }

        if(cage){
            filters.push(LABKEY.Filter.create('cage', cage, LABKEY.Filter.Types.EQUAL))
        }

        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'housing',
            viewName: 'Active Housing',
            sort: 'Id',
            filterArray: filters,
            scope: this,
            success: function(rows){
                var subjectArray = [];
                Ext4.each(rows.rows, function(r){
                    subjectArray.push(r.Id);
                }, this);
                subjectArray = Ext4.unique(subjectArray);
                if(subjectArray.length){
                    this.tabbedReportPanel.setSubjGrid(true, false, subjectArray);
                }
                Ext4.Msg.hide();
            },
            failure: LDK.Utils.getErrorCallback()
        });
    }
});