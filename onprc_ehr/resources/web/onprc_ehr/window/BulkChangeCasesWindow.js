/*
 * Copyright (c) 2014-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg sourceStore
 */
Ext4.define('ONPRC_EHR.window.BulkChangeCasesWindow', {
    extend: 'Ext.window.Window',
    minWidth: 750,
    minHeight: 200,

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Bulk Close Cases',
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
                text: 'Cancel',
                handler: function(btn){
                    btn.up('window').close();
                }
            }]
        });

        this.callParent(arguments);

        this.getDemographics();
    },

    getDemographics: function(){
        var caseIds = [];
        this.sourceStore.each(function(rec){
            if (!rec.get('caseid')){
                return;
            }

            caseIds.push(rec.get('caseid'));
        }, this);

        caseIds = Ext4.unique(caseIds);
        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'cases',
            filterArray: [LABKEY.Filter.create('objectid', caseIds.join(';'), LABKEY.Filter.Types.IN)],
            scope: this,
            failure: LDK.Utils.getErrorCallback(),
            success: this.onLoad,
            columns: 'objectid,Id,date,remark,category,reviewdate,enddate'
        });
    },

    onLoad: function(results){
        if (!results || !results.rows || !results.rows.length){
            Ext4.Msg.alert('Error', 'No matching cases found');
            return;
        }

        var caseIdMap = {};
        Ext4.Array.forEach(results.rows, function(row){
            caseIdMap[row.objectid] = row;
        }, this);

        var toAdd = [];
        this.sourceStore.each(function(rec, rowIdx){
            if (!rec.get('caseid')){
                return;
            }

            var caseRow = caseIdMap[rec.get('caseid')];
            LDK.Assert.assertNotEmpty('Unable to find case record for: ' + rec.get('caseid'), caseRow);

            toAdd.push({
                xtype: 'displayfield',
                value: rec.get('Id'),
                fieldName: 'Id',
                caseLsid: caseRow.lsid,
                rowIdx: rowIdx
            });

            toAdd.push({
                xtype: 'displayfield',
                value: caseRow.remark,
                fieldName: 'remark',
                width: 300,
                rowIdx: rowIdx
            });

            toAdd.push({
                xtype: 'displayfield',
                value: LDK.ConvertUtils.parseDate(caseRow.date).format(LABKEY.extDefaultDateFormat)
            });

            toAdd.push({
                xtype: 'datefield',
                width: 120,
                fieldName: 'reviewdate',
                value: LDK.ConvertUtils.parseDate(caseRow.reviewdate),
                rowIdx: rowIdx,
                listeners: {
                    blur: function(field){
                        field.onValueChange();
                    },
                    select: function(field){
                        field.onValueChange();
                    }
                },
                onValueChange: function(){
                    var val = this.getValue();
                    if (!val || !this.parseDate(val)){
                        return;
                    }

                    var win = this.up('window');
                    var enddateField = win.query('datefield[rowIdx=' + this.rowIdx + '][fieldName=enddate]')[0];
                    if (val && enddateField.getValue()){
                        Ext4.Msg.confirm('Case Already Closed', 'You have entered a review date for a case that is already marked as permanently closed (ie. has an end date).  Do you want to do this?', function(v){
                            if (v == 'yes'){
                                enddateField.setValue(null);
                            }
                            else {
                                this.setValue(null);
                            }
                        }, this);
                    }
                }
            });

            toAdd.push({
                xtype: 'datefield',
                width: 120,
                fieldName: 'enddate',
                value: LDK.ConvertUtils.parseDate(caseRow.enddate),
                rowIdx: rowIdx,
                listeners: {
                    blur: function(field){
                        field.onFieldValueChange();
                    },
                    select: function(field){
                        field.onFieldValueChange();
                    }
                },
                onFieldValueChange: function(){
                    var val = this.getValue();
                    var win = this.up('window');

                    var reviewField = win.query('datefield[rowIdx=' + this.rowIdx + '][fieldName=reviewdate]')[0];
                    if (val && reviewField.getValue()){
                        Ext4.Msg.confirm('Case Already Closed for Review', 'You have entered an end date for a case that is already marked as closed for review (ie. it will automatically re-open on the selected date).  This will permanently close that case.  Do you want to do this?', function(v){
                            if (v == 'yes'){
                                reviewField.setValue(null);
                            }
                            else {
                                this.setValue(null);
                            }
                        }, this);
                    }
                }
            });

            toAdd.push({
                xtype: 'button',
                text: 'Close',
                border: true,
                width: 50,
                rowIdx: rowIdx,
                handler: function(btn){
                    var win = btn.up('window');

                    var field = win.query('datefield[rowIdx=' + btn.rowIdx + '][fieldName=enddate]')[0];
                    var reviewField = win.query('datefield[rowIdx=' + btn.rowIdx + '][fieldName=reviewdate]')[0];
                    if (field.getValue()){
                        Ext4.Msg.alert('Error', 'This case already has a close date');
                    }
                    else {
                        field.setValue(new Date());
                        reviewField.setValue(null);
                    }
                }
            });
        }, this);

        this.removeAll();

        if (toAdd.length){
            toAdd = [{
                html: 'Id'
            },{
                html: 'Case Description',
                width: 250
            },{
                html: 'Open Date',
                width: 100
            },{
                html: 'Review Date',
                width: 100
            },{
                html: 'Close Date',
                width: 100
            },{

            }].concat(toAdd);

            this.add([{
                html: 'This helper allows you to modify the close or review date of cases in bulk.  To close a case, either hit the close case button, or enter the desired close date into the appropriate field.  If you would like to close a case for review (ie. automatically re-open on the chosen date), enter a date into the field.  Note: you should not enter both a review date and a close date, since this marks the case as closed and it will not re-open.',
                border: false,
                style: 'padding-bottom: 20px;',
                width: 750
            },{
                defaults: {
                    style: 'margin-right: 5px;',
                    border: false
                },
                border: false,
                layout: {
                    type: 'table',
                    tdAttrs: {
                        valign: 'top'
                    },
                    columns: 6
                },
                items: toAdd
            }]);

            this.center();
        }
        else {
            this.add({
                html: 'No IDs To Show'
            });
        }
    },

    onSubmit: function(){
        var caseRecordsToUpdate = [];

        var idFields = this.query('field[fieldName=Id]');
        Ext4.Array.forEach(idFields, function(idField){
            var id = idField.getValue();
            var caseLsid = idField.caseLsid;

            var obj = {};

            var enddateField = this.query('field[rowIdx=' + idField.rowIdx + '][fieldName=enddate]')[0];
            if (enddateField.isDirty()){
                obj.enddate = enddateField.getValue();
            }

            var reviewdateField = this.query('component[rowIdx=' + idField.rowIdx + '][fieldName=reviewdate]')[0];
            if (reviewdateField.isDirty()){
                obj.reviewdate = reviewdateField.getValue();
            }

            if (!Ext4.Object.isEmpty(obj)) {
                obj.lsid = caseLsid;
                obj.Id = id;
                caseRecordsToUpdate.push(obj);
            }
        }, this);

        if (caseRecordsToUpdate.length){
            this.hide();
            Ext4.Msg.wait('Loading...');

            LABKEY.Query.updateRows({
                schemaName: 'study',
                queryName: 'cases',
                rows: caseRecordsToUpdate,
                scope: this,
                failure: LDK.Utils.getErrorCallback(),
                success: function(results){
                    this.close();
                    Ext4.Msg.hide();
                    Ext4.Msg.alert('Success', 'Cases updated');

                    var ids = [];
                    Ext4.Array.forEach(caseRecordsToUpdate, function(r){
                        ids.push(r.Id);
                    }, this);
                    ids = Ext4.Array.unique(ids);

                    EHR.DemographicsCache.clearCache(ids);
                }
            });
        }
        else {
            this.close();
            Ext4.Msg.alert('Complete', 'There are no cases to modify');
        }
    }
});

EHR.DataEntryUtils.registerGridButton('BULK_CHANGE_CASES', function(config){
    config = config || {};

    return Ext4.Object.merge({
        text: 'Bulk Close Cases',
        name: 'bulkChangeCases',
        itemId: 'bulkChangeCases',
        requiredPermissions: [
            [EHR.QCStates.COMPLETED, 'update', [
                {schemaName: 'study', queryName: 'Cases'}
            ]]
        ],
        handler: function (btn) {
            var panel = btn.up('ehr-dataentrypanel');
            LDK.Assert.assertNotEmpty('Unable to find dataentrypanel from BULK_CHANGE_CASES button', panel);

            //find id
            var clientStore = panel.storeCollection.getClientStoreByName('clinRemarks') || panel.storeCollection.getClientStoreByName('Clinical Remarks');
            LDK.Assert.assertNotEmpty('Unable to find clientStore from BULK_CHANGE_CASES button', clientStore);

            if (!clientStore.getCount()) {
                Ext4.Msg.alert('Error', 'No Cases Entered');
                return;
            }

            Ext4.create('ONPRC_EHR.window.BulkChangeCasesWindow', {
                sourceStore: clientStore
            }).show();
        }
    }, config);
});
