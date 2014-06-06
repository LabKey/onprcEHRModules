/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg targetStore
 */
Ext4.define('ONPRC_EHR.window.BloodAddBulkWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Bulk Add Blood Draws',
            bodyStyle: 'padding: 5px;',
            width: 800,
            fieldNames: ['Id', 'Date', 'Project', 'Tube Type', 'Quantity'],
            fields: ['Id', 'date', 'project', 'tube_type', 'quantity'],
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import blood draw using a simple excel file.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Template]',
                scope: this,
                handler: function(){
                    LABKEY.Utils.convertToExcel({
                        fileName: 'Blood Request.xlsx',
                        sheets: [{
                            name: 'Requests',
                            data: [
                                this.fieldNames
                            ]
                        }]
                    });
                }
            },{
                xtype: 'textarea',
                width: 770,
                height: 400,
                itemId: 'textField'
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

        this.projectStore = EHR.DataEntryUtils.getProjectStore();

        this.callParent(arguments);
    },

    onSubmit: function(){
        var text = this.down('#textField').getValue();
        if (!text){
            Ext4.Msg.alert('Error', 'Must paste the records into the textarea');
            return;
        }

        var parsed = LDK.Utils.CSVToArray(Ext4.String.trim(text), '\t');
        if (!parsed){
            Ext4.Msg.alert('Error', 'There was an error parsing the excel file');
            return;
        }

        if (parsed.length < 2){
            Ext4.Msg.alert('Error', 'There are not enough rows in the text, there was an error parsing the excel file');
            return;
        }

        this.doParse(parsed);
    },

    doParse: function(parsed){
        var errors = [];
        var records = [];

        //first get global values:
        Ext4.Msg.wait('Processing...');

        for (var i=1;i<parsed.length;i++){
            var row = parsed[i];
            if (!row || row.length < 5){
                errors.push('Row ' + i + ': not enough items in row');
                continue;
            }

            var newRow = this.processRow(row, errors, i);
            if (newRow){
                records.push(this.targetStore.createModel(newRow));
            }
        }

        Ext4.Msg.hide();

        if (errors.length){
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }

        //blood
        if (records.length){
            this.targetStore.add(records);
        }

        this.close();
    },

    processRow: function(row, errors, rowIdx){
        var obj = {
            Id: row[0],
            date: LDK.ConvertUtils.parseDate(row[1]),
            project: this.resolveProjectByName(row[2], errors, rowIdx),
            tube_type: row[3],
            quantity: row[4]
        };

        if (!this.checkRequired(['Id', 'date', 'project', 'tube_type', 'quantity'], obj, errors, rowIdx)){
            return obj;
        }
    },

    checkRequired: function(fields, row, errors, rowIdx){
        var hasErrors = false,
                fieldName;
        for (var i=0;i<fields.length;i++){
            fieldName = fields[i];
            if (Ext4.isEmpty(row[fieldName])){
                errors.push('Row ' + rowIdx + ': missing field ' + fieldName);
                hasErrors = true;
            }
        }

        return hasErrors;
    },

    resolveProjectByName: function(projectName, errors, rowIdx){
        if (!projectName){
            return null;
        }

        projectName = Ext4.String.leftPad(projectName, 4, '0');

        var recIdx = this.projectStore.find('name', projectName);
        if (recIdx == -1){
            errors.push('Row ' + rowIdx + ': unknown project ' + projectName);
            return null;
        }

        return this.projectStore.getAt(recIdx).get('project');
    }
});

EHR.DataEntryUtils.registerGridButton('BULK_ADD_BLOOD', function(config){
    return Ext4.Object.merge({
        text: 'Add From Excel',
        tooltip: 'Click to bulk import records from an excel file',
        handler: function(btn){
            var grid = btn.up('grid');
            LDK.Assert.assertNotEmpty('Unable to find grid in BULK_ADD_BLOOD button', grid);

            Ext4.create('ONPRC_EHR.window.BloodAddBulkWindow', {
                targetStore: grid.store
            }).show();
        }
    });
});
