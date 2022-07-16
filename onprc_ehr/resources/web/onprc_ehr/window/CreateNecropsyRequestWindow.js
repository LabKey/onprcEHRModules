Ext4.define('ONPRC_EHR.window.CreateNecropsyRequestWindow', {
    extend: 'Ext.window.Window',

    statics: {
        /**
         * This add a button that allows the user to create a task from a list of IDs, that contains one record per ID.  It was originally
         * created to allow users to create a weight task based on a list of IDs (like animals needed weights).
         */
        createTaskFromRecordHandler: function(dataRegionName, formType){
            var dataRegion = LABKEY.DataRegions[dataRegionName];
            var checked = dataRegion.getChecked();
            if (!checked || !checked.length){
                Ext4.Msg.alert('Error', 'No records selected');
                return;
            }

            Ext4.create('ONPRC_EHR.window.CreateNecropsyRequestWindow', {
                dataRegionName: dataRegionName,
                title: 'Schedule Pathology For Selected Rows',
                formType: formType,
                taskLabel: 'Pathology Request'
            }).show();
        }
    },



    initComponent: function(){
        LDK.Assert.assertNotEmpty('Missing formtype in CreateTaskFromRecordsWindow', this.formType);
        var requestid = [];
        Ext4.apply(this, {
            modal: true,
            border: false,
            closeAction: 'destroy',
            width: 400,
            items: [{
                xtype: 'form',
                itemId: 'theForm',
                bodyStyle: 'padding: 5px;',
                border: false,
                defaults: {
                    border: false,
                    width: 360
                },
                items: [{
                    html: 'Total Selected: ' + '<br><br>',
                    border: false
                },{
                    xtype: 'textfield',
                    fieldLabel: 'Task Title',
                    value: this.taskLabel,
                    itemId: 'titleField'
                },{
                    xtype: 'xdatetime',
                    fieldLabel: 'Date',
                    value: new Date(),
                    itemId: 'date'
                },{
                    xtype: 'combo',
                    fieldLabel: 'Assigned To',
                    forceSelection: true,
                    value: LABKEY.Security.currentUser.id,
                    queryMode: 'local',
                    store: {
                        type: 'labkey-store',
                        schemaName: 'core',
                        queryName: 'PrincipalsWithoutAdmin',
                        columns: 'UserId,DisplayName',
                        sort: 'Type,DisplayName',
                        autoLoad: true
                    },
                    displayField: 'DisplayName',
                    valueField: 'UserId',
                    itemId: 'assignedTo'
                },{
                    xtype: 'checkbox',
                    fieldLabel: 'View Task After Created?',
                    itemId: 'viewAfterCreate',
                    checked: true
                }]
            }],
            buttons: this.getButtonCfg()
        });

        this.callParent();

        this.on('render', function(){
            this.setLoading(true);
            this.loadData();
        }, this, {single: true, delay: 100});
    },

    getButtonCfg: function(){
        return [{
            text: 'Submit',
            itemId: 'submitBtn',
            scope: this,
            disabled: true,
            handler: this.onSubmit
        },{
            text: 'Cancel',
            handler: function(btn){
                btn.up('window').close();
            }
        }];
    },

    loadData: function(){
        var dataRegion = LABKEY.DataRegions[this.dataRegionName];
        LDK.Assert.assertNotEmpty('Unknown dataregion: ' + this.dataRegionName, dataRegion);

        this.checkedRows = dataRegion.getChecked();

        LABKEY.Query.selectRows({
            method: 'POST',
            requiredVersion: 9.1,
            schemaName: dataRegion.schemaName,
            queryName: dataRegion.queryName,
            sort: 'Id,date',
            columns: 'requestid',
            filterArray: [LABKEY.Filter.create('lsid', this.checkedRows.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF)],
            scope: this,
            success: this.getNecropsyRequestData,
            failure: LDK.Utils.getErrorCallback()
        });
    },

    getNecropsyRequestData: function (data) {

        Ext4.Array.forEach(data.rows, function(row){
            var requestid = row.requestid;

            LABKEY.Query.selectRows({
                schemaName: 'study',
                queryName: 'StudyData',
                sort: 'Id,date',
                columns: 'lsid,Id,date,requestid,taskid,qcstate,qcstate/label,qcstate/metadata/isRequest,DataSet/Label',
                filterArray: [LABKEY.Filter.create('requestid', requestid.value, LABKEY.Filter.Types.EQUAL)],
                scope: this,
                success: this.onDataSuccess,
                failure: LDK.Utils.getErrorCallback()
            });

        }, this);
    },

    onDataSuccess: function (data) {
        if (!data || !data.rows){
            Ext4.Msg.hide();
            Ext4.Msg.alert('Error', 'No records found');
            return;
        }

        this.records = [];
        var errors = [];

        Ext4.Array.forEach(data.rows, function(row){
            this.records.push(row);

        }, this);

        if (errors.length){
            errors = Ext4.Array.unique(errors);
            Ext4.Msg.alert('Error', errors.join('<br>'));
        }

        if (this.showTotalSelectedCount) {
            var form = this.down('#theForm');
            form.remove(0);
            form.insert(0, {
                html: 'Total Selected: ' + this.records.length + '<br><br>',
                border: false
            });
        }

        this.afterDataLoad();
    },

    afterDataLoad: function() {
        this.down('#submitBtn').setDisabled(false);
        this.setLoading(false);
    },

    onSubmit: function(){
        var records = this.records;
        if (!records || !records.length)
            return;

        this.doSave(records);
    },

    doSave: function(records){
        var date = this.down('#date').getValue();
        if(!date){
            Ext4.Msg.alert('Error', 'Must enter a date');
            return;
        }

        var assignedTo = this.down('#assignedTo').getValue();
        if(!assignedTo){
            Ext4.Msg.alert('Error', 'Must assign to someone');
            return;
        }

        var title = this.down('#titleField').getValue();
        if(!title){
            Ext4.Msg.alert('Error', 'Must enter a title');
            return;
        }

        Ext4.Msg.wait('Saving...');

        var existingRecords = {};

        Ext4.Array.forEach(records, function(r){
            LDK.Assert.assertNotEmpty('Record does not have an LSID', r.lsid);
            var dataSetName = r['DataSet/Label'];
            if(!existingRecords[dataSetName]) {
                existingRecords[dataSetName] = []
            }
            existingRecords[dataSetName].push({lsid: r.lsid});
        }, this);

        EHR.Utils.createTask({
            initialQCState: 'Scheduled',
            existingRecords: existingRecords,
            taskRecord: {date: date, assignedTo: assignedTo, category: 'task', title: title, formType: this.formType},
            scope: this,
            success: this.createTaskSuccess,
            failure: LDK.Utils.getErrorCallback()
        });
    },

    createTaskSuccess: function(response, options, config){
        Ext4.Msg.hide();

        var viewAfterCreate = this.down('#viewAfterCreate').getValue();
        this.close();

        if (viewAfterCreate){
            window.location = LABKEY.ActionURL.buildURL('ehr', 'dataEntryForm', null, {taskid: config.taskId, formType: this.formType});
        }
        else {
            LABKEY.DataRegions[this.dataRegionName].refresh();
        }
    }
});