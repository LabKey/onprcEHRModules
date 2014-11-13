/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel
 */
Ext4.define('EHR.window.BehaviorCasesWindow', {
    extend: 'Ext.window.Window',
    minHeight: 200,

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            width: 500,
            closeAction: 'destroy',
            title: 'Manage Cases',
            bodyStyle: 'padding: 5px;',
            items: [{
                html: 'Loading...',
                border: false
            }],
            buttons: [{
                text: 'Submit',
                scope: this,
                handler: this.onSubmit
            },{
                text: 'Close',
                handler: function(btn){
                    btn.up('window').close();
                }
            }]
        });

        this.callParent(arguments);

        this.getCaseDetails();
    },

    getCaseDetails: function(){
        var caseIds = [];
        this.dataEntryPanel.storeCollection.clientStores.each(function(cs){
            if (cs.getFields().get('caseid')){
                cs.each(function(rec){
                    if (rec.get('Id') && rec.get('caseid')){
                        caseIds.push(rec.get('caseid'));
                    }
                }, this);
            }
        }, this);

        if (!caseIds.length){
            Ext4.Msg.alert('Error', 'No Cases To Manage');
        }
        else {
            caseIds = Ext4.unique(caseIds);
            Ext4.Msg.wait('Loading...');
            LABKEY.Query.selectRows({
                schemaName: 'study',
                queryName: 'cases',
                columns: 'Id,lsid,allProblemCategories',
                filterArray: [LABKEY.Filter.create('objectid', caseIds.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)],
                scope: this,
                sort: 'Id',
                failure: LDK.Utils.getErrorCallback(),
                success: this.onLoad
            });
        }
    },

    onLoad: function(results){
        var toAdd = [];
        var columns = 3;

        Ext4.Msg.hide();
        if (!results || !results.rows && !results.rows.length){
            Ext4.Msg.alert('Error', 'No Cases Found');
            return;
        }
        var reviewDate = Ext4.Date.clearTime(Ext4.Date.add(new Date(), Ext4.Date.DAY, 14));
        Ext4.Array.forEach(results.rows, function(row, rowIdx){
            toAdd.push({
                xtype: 'displayfield',
                value: row.Id,
                fieldName: 'Id',
                width: 100,
                rowIdx: rowIdx
            });

            toAdd.push({
                xtype: 'displayfield',
                value: row.allProblemCategories,
                fieldName: 'problems',
                width: 160,
                rowIdx: rowIdx
            });

            toAdd.push({
                xtype: 'datefield',
                fieldName: 'date',
                width: 120,
                rowIdx: rowIdx,
                lsid: row.lsid,
                value: reviewDate
            });
        }, this);

        this.removeAll();

        if (toAdd.length){
            toAdd = [{
                html: 'Id',
                style: 'padding-top: 10px;'
            },{
                html: 'Problem(s)',
                width: 120
            },{
                html: 'Review Date',
                width: 120
            }].concat(toAdd);

            this.add({
                html: 'This helper allows you to close cases for review in bulk.  In order to skip a given animal, leave the date field blank.  Use the \'Change All\' field to set the review date for all cases.',
                style: 'padding-bottom: 10px;',
                border: false
            });

            this.add([{
                layout: 'hbox',
                border: false,
                items: [{
                    xtype: 'datefield',
                    itemId: 'changeAll',
                    minDate: Ext4.Date.clearTime(new Date()),
                    width: 200
                },{
                    xtype: 'button',
                    style: 'margin-left: 10px;',
                    text: 'Change All',
                    handler: function (btn) {
                        var win = btn.up('window');
                        var field = win.down('#changeAll');
                        var val = field.getValue();

                        var fields = win.query('field[fieldName=date]');
                        Ext4.Array.forEach(fields, function (f) {
                            f.setValue(val);
                        }, this);

                        field.setValue(null);
                    }
                }]
            },{
                html: '<hr>',
                border: false
            },{
                defaults: {
                    style: 'margin-right: 5px;',
                    border: false
                },
                border: false,
                layout: {
                    type: 'table',
                    columns: columns
                },
                items: toAdd
            }]);
        }
        else {
            this.add({
                html: 'No IDs To Show',
                border: false
            });
        }
    },

    onSubmit: function(){
        var caseRecordsToUpdate = [];
        var cbs = this.query('datefield');
        Ext4.Array.forEach(cbs, function(cb){
            if (cb.getValue()){
                caseRecordsToUpdate.push({
                    lsid: cb.lsid,
                    reviewdate: cb.getValue()
                });
            }
        }, this);

        if (caseRecordsToUpdate.length){
            Ext4.Msg.wait('Saving...');
            LABKEY.Query.updateRows({
                schemaName: 'study',
                queryName: 'cases',
                rows: caseRecordsToUpdate,
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: function(results){
                    this.close();
                    Ext4.Msg.hide();
                }
            });
        }
        else {
            this.close();
            Ext4.Msg.alert('Complete', 'There are no cases to modify');
        }
    }
});

EHR.DataEntryUtils.registerDataEntryFormButton('BEHAVIOR_CASES', {
    text: 'Close/Review Cases',
    name: 'behaviorCase',
    successURL: LABKEY.ActionURL.getParameter('srcURL') || LABKEY.ActionURL.buildURL('ehr', 'enterData.view'),
    disabled: true,
    itemId: 'behaviorCase',
    requiredPermissions: [
        [EHR.QCStates.COMPLETED, 'update', [{schemaName: 'study', queryName: 'Cases'}]]
    ],
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataentrypanel from BEHAVIOR_CASES button', panel);

        Ext4.create('EHR.window.BehaviorCasesWindow', {
            dataEntryPanel: panel
        }).show();
    }
});
