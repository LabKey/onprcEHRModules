/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataRegion
 * @cfg subjectIds
 * @cfg successHandler
 */
Ext4.define('ONPRC_EHR.window.ManageFlagsWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        this.ehrCtx = EHR.Utils.getEHRContext();
        if (!this.ehrCtx){
            alert('EHRStudyContainer has not been set in this folder');
            return;
        }

        Ext4.apply(this, {
            width: 430,
            autoHeight: true,
            modal: true,
            bodyStyle: 'padding:5px',
            closeAction: 'destroy',
            title: 'Manage Flags',
            items: [{
                xtype: 'form',
                fieldDefaults: {
                    width: 400
                },
                border: false,
                items: [{
                    html: 'Note: flags will only be added to living animals, and will only be added if a flag of this type does not already exist',
                    border: false,
                    style: 'padding-bottom: 10px;'
                },{
                    xtype: 'combo',
                    fieldLabel: 'Action Type',
                    itemId: 'modeField',
                    displayField: 'value',
                    valueField: 'value',
                    store: {
                        type: 'array',
                        fields: ['value'],
                        data: [['Add'], ['Remove']]
                    }
                },{
                    xtype: 'datefield',
                    itemId: 'dateField',
                    fieldLabel: 'Effective Date',
                    value: new Date()
                },{
                    xtype: 'combo',
                    fieldLabel: 'Flag',
                    itemId: 'flagValue',
                    displayField: 'value',
                    valueField: 'objectid',
                    caseSensitive: false,
                    anyMatch: true,
                    triggerAction: 'all',
                    queryMode: 'local',
                    matchFieldWidth: false,
                    typeAhead: true,
                    listConfig: {
                        innerTpl: '{[(values.category ? "<b>" + values.category + ":</b> " : "") + values.value + (values.code ? " (" + values.code + ")" : "")]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    },
                    store: {
                        type: 'labkey-store',
                        schemaName: 'ehr_lookups',
                        queryName: 'flag_values',
                        columns: 'objectid,category,code,value',
                        sort: 'category,code,value',
                        autoLoad: true
                    }
                },{
                    xtype: 'textarea',
                    fieldLabel: 'Remark',
                    itemId: 'remarkField'
                }]
            }],
            buttons: [{
                xtype: 'button',
                text: 'Submit',
                scope: this,
                handler: this.onSubmit
            },{
                xtype: 'button',
                text: 'Cancel',
                handler: function(btn){
                    btn.up('window').destroy();
                }
            }]
        });

        this.callParent();
    },

    onSubmit: function(btn){
        var date = this.down('#dateField').getValue();
        if (!date){
            alert('Must enter a date');
            return;
        }

        var mode = this.down('#modeField').getValue();
        if (!mode){
            alert('Must enter the action type');
            return;
        }
        mode = mode.toLowerCase();

        var params = {
            mode: mode,
            animalIds: this.subjectIds,
            performedby: LABKEY.Security.currentUser.displayName
        };
        params[mode == 'add' ? 'date' : 'enddate'] = date;

        var remark = this.down('#remarkField').getValue();
        if (remark)
            params.remark = remark;

        var flag = this.down('#flagValue').getValue();
        if (!flag){
            alert('Must choose a flag');
            return;
        }
        params.flag = flag;

        Ext4.Msg.wait('Saving...');

        LABKEY.Ajax.request({
            url: LABKEY.ActionURL.buildURL('ehr', 'manageFlags', this.ehrCtx.EHRStudyContainer),
            method: 'POST',
            params: params,
            scope: this,
            success: LABKEY.Utils.getCallbackWrapper(this.successHandler, this),
            failure: LDK.Utils.getErrorCallback({
                showAlertOnError: false,
                scope: this,
                callback: function(response){
                    var msg;
                    if (response && response.responseText){
                        var json = Ext4.decode(response.responseText);
                        if (json && json.exception){
                            msg = json.exception;
                        }
                    }

                    msg = msg || 'There was an error saving the data';
                    Ext4.Msg.alert('Error', msg);
                }
            })
        });
    },

    successHandler: function(response){
        Ext4.Msg.hide();
        this.close();

        var added = response.added || [];
        var removed = response.removed || [];
        Ext4.Msg.alert('Success', 'Flags have been updated.  A total of ' + added.length + ' animals had flags added and ' + removed.length + ' had flags removed.  These numbers may differ from the total rows selected because flags are only added/removed if the animal needs them, and will only be added to animals actively at the center.', function(){
            this.dataRegion.refresh();
        }, this);
    },

    statics: {
        buttonHandler: function(dataRegionName){
            var dataRegion = LABKEY.DataRegions[dataRegionName];
            var checked = dataRegion.getChecked();
            if (!checked || !checked.length){
                alert('No records selected');
                return;
            }

            var ctx = EHR.Utils.getEHRContext();
            if (!ctx){
                alert('EHRStudyContainer has not been set in this folder');
                return;
            }

            if (!ctx.EHRStudyContainerInfo || ctx.EHRStudyContainerInfo.effectivePermissions.indexOf(EHR.Security.Permissions.DATA_ENTRY) == -1){
                alert('You do not have data entry permission in EHR');
                return;
            }

            //resolve PKs into IDs
            var selectorCols = !Ext4.isEmpty(dataRegion.selectorCols) ? dataRegion.selectorCols : dataRegion.pkCols;
            LDK.Assert.assertNotEmpty('Unable to find selector columns for: ' + dataRegion.schemaName + '.' + dataRegion.queryName, selectorCols);

            Ext4.Msg.wait('Loading...');
            LABKEY.Query.selectRows({
                containerPath: ctx.EHRStudyContainer,
                schemaName: dataRegion.schemaName,
                queryName: dataRegion.queryName,
                filterArray: [LABKEY.Filter.create(selectorCols[0], checked.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)],
                columns: 'Id',
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: function(results){
                    Ext4.Msg.hide();

                    if (!results || !results.rows || !results.rows.length){
                        Ext4.Msg.alert('Error', 'No matching animals were found');
                        return;
                    }

                    var subjectIds = [];
                    Ext4.Array.forEach(results.rows, function(r){
                        subjectIds.push(r.Id);
                    }, this);

                    Ext4.create('ONPRC_EHR.window.ManageFlagsWindow', {
                        subjectIds: subjectIds,
                        dataRegion: dataRegion
                    }).show();
                }
            });
        }
    }
});