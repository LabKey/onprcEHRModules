/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.AssignmentDefaultsWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            bodyStyle: 'padding: 5px;',
            width: 450,
            title: 'Set Assignment Values',
            items: [{
                html: 'This helper will populate the current condition for the selected records (based on flags), and/or the projected release date (based on the grant funding source).',
                style: 'padding-bottom: 10px;',
                border: false
            },{
                xtype: 'checkbox',
                itemId: 'conditionField',
                checked: true,
                boxLabel: 'Populate Initial Condition'
            },{
                xtype: 'checkbox',
                itemId: 'projectedReleaseField',
                checked: true,
                boxLabel: 'Populate Projected Release'
            }],
            buttons: [{
                text: 'Submit',
                scope: this,
                handler: this.onSubmit
            },{
                text: 'Cancel',
                handler: function(btn){
                    btn.up('window').close();
                }
            }]
        });

        this.callParent(arguments);
    },

    onSubmit: function(){
        var condition = this.down('#conditionField').getValue();
        var projectedRelease = this.down('#projectedReleaseField').getValue();

        if (!condition && !projectedRelease){
            Ext4.Msg.alert('Error', 'Must select either condition, projected relase or both');
            return;
        }

        var ids = [];
        var projects = [];
        this.targetGrid.store.each(function(r){
            if (r.get('Id')){
                ids.push(r.get('Id'));
            }

            if (r.get('project')){
                projects.push(r.get('project'));
            }
        }, this);

        ids = Ext4.unique(ids);
        projects = Ext4.unique(projects);

        if (!ids.length && !projects.length){
            Ext4.Msg.alert('Nothing To Set', 'There are no IDs or projects to set');
        }
        else {
            Ext4.Msg.wait('Loading...');
            var multi = new LABKEY.MultiRequest();

            this.conditionData = {};
            if (ids.length){
                multi.add(LABKEY.Query.selectRows, {
                    schemaName: 'study',
                    queryName: 'demographicsCondition',
                    columns: 'Id,condition,codes',
                    filterArray: [
                        LABKEY.Filter.create('Id', ids.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)
                    ],
                    scope: this,
                    failure: LDK.Utils.getErrorCallback(),
                    success: function(results){
                        if (results && results.rows && results.rows.length){
                            Ext4.Array.forEach(results.rows, function(r){
                                if (r.codes){
                                    if (Ext4.isArray(r.codes) && r.codes.length == 1){
                                        this.conditionData[r.Id] = r.codes[0];
                                    }
                                    else if (r.codes && r.codes.match(/,/)){
                                        this.conditionData[r.Id] = r.codes;
                                    }
                                }
                            }, this);
                        }
                    }
                });
            }

            this.projectData = {};
            if (projects.length){
                multi.add(LABKEY.Query.selectRows, {
                    schemaName: 'ehr',
                    queryName: 'project',
                    columns: 'project,account/grantNumber/budgetEndDate',
                    filterArray: [
                        LABKEY.Filter.create('project', projects.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)
                    ],
                    scope: this,
                    failure: LDK.Utils.getErrorCallback(),
                    success: function(results){
                        if (results && results.rows && results.rows.length){
                            Ext4.Array.forEach(results.rows, function(r){
                                if (r.project && r['account/grantNumber/budgetEndDate']){
                                    this.projectData[r.project] = LDK.ConvertUtils.parseDate(r['account/grantNumber/budgetEndDate']);
                                }
                            }, this);
                        }
                    }
                });
            }

            multi.send(this.onComplete, this);
        }
    },

    onComplete: function(){
        Ext4.Msg.hide();
        var condition = this.down('#conditionField').getValue();
        var projectedRelease = this.down('#projectedReleaseField').getValue();

        this.targetGrid.store.suspendEvents();
        var changed = false;
        this.targetGrid.store.each(function(r){
            if (condition && r.get('Id') && this.conditionData[r.get('Id')]){
                r.set('assignCondition', this.conditionData[r.get('Id')]);
                changed = true;
            }

            if (projectedRelease && r.get('project') && this.projectData[r.get('project')]){
                r.set('projectedRelease', this.projectData[r.get('project')]);
                changed = true;
            }
        }, this);

        this.targetGrid.store.resumeEvents();
        if (changed){
            this.targetGrid.store.fireEvent('datachanged', this.targetGrid.store);
            this.targetGrid.getView().refresh();
        }

        this.close();
    }
});

EHR.DataEntryUtils.registerGridButton('SET_ASSIGNMENT_DEFAULTS', function(config){
    config = config || {};

    return Ext4.Object.merge({
        text: 'Set Defaults',
        handler: function(btn){
            var grid = btn.up('gridpanel');
            LDK.Assert.assertNotEmpty('Unable to find gridpanel in SET_ASSIGNMENT_DEFAULTS button', grid);

            Ext4.create('ONPRC_EHR.window.AssignmentDefaultsWindow', {
                targetGrid: grid
            }).show();
        }
    }, config);
});