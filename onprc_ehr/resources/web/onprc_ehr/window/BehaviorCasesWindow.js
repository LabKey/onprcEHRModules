/**
 * @cfg dataEntryPanel
 */
Ext4.define('EHR.window.BehaviorCasesWindow', {
    extend: 'Ext.window.Window',
    width: 400,
    minHeight: 200,

    initComponent: function(){
        LABKEY.ExtAdapter.apply(this, {
            modal: true,
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
        var idMap = [];
        this.dataEntryPanel.storeCollection.clientStores.each(function(cs){
            if (cs.getFields().get('caseid')){
                cs.each(function(rec){
                    if (rec.get('Id') && rec.get('caseid')){
                        idMap[rec.get('Id')] = rec.get('caseid');
                    }
                }, this);
            }
        }, this);

        if (Ext4.Object.isEmpty(idMap)){
            Ext4.Msg.alert('Error', 'No Cases To Manage');
        }
        else {
            Ext4.Msg.wait('Loading...');
            LABKEY.Query.selectRows({
                schemaName: 'study',
                queryName: 'cases',
                columns: 'Id,lsid',
                filterArray: [LABKEY.Filter.create('objectid', Ext4.Object.getValues(idMap).join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)],
                scope: this,
                sort: 'Id',
                failure: LDK.Utils.getErrorCallback(),
                success: this.onLoad
            });
        }
    },

    onLoad: function(results){
        var toAdd = [];
        var columns = 2;

        Ext4.Msg.hide();
        if (!results || !results.rows && !results.rows.length){
            Ext4.Msg.alert('Error', 'No Cases Found');
            return;
        }
        var reviewDate = Ext4.Date.add(new Date(), Ext4.Date.DAY, 14);
        Ext4.Array.forEach(results.rows, function(row, rowIdx){
            toAdd.push({
                xtype: 'displayfield',
                value: row.Id,
                fieldName: 'Id',
                width: 120,
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
                html: 'Id'
            },{
                html: 'Review Date',
                width: 120
            }].concat(toAdd);

            this.add({
                html: 'This helper allows you to close cases for review in bulk.  In order to skip a given animal, leave the date field blank.',
                style: 'padding-bottom: 10px;',
                border: false
            });

            this.add({
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
            });
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
