/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel      Created 1/17/2024   Blasa    Environmental ATP Entries
 */
Ext4.define('ONPRC_EHR.window.MiscCharges_ScanWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Misc Charges Bulk Data Import',
            bodyStyle: 'padding: 5px;',
            width: 800,
            defaults: {
                border: false
            },
            items: [{
                html : 'This program allows you to import record using the Misc_Charges_ScanWindow Excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/Misc_Charges_Template.xlsx'
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


        this.callParent(arguments);
    },

    onSubmit: function(){
        var text = this.down('#textField').getValue();
        if (!text){
            Ext4.Msg.alert('Error', 'Must paste the records into the text area');
            return;
        }

        var parsed = LDK.Utils.CSVToArray(Ext4.String.trim(text), '\t');
        if (!parsed){
            Ext4.Msg.alert('Error', 'There was an error parsing your excel file');
            return;
        }

        if (parsed.length < 2){
            Ext4.Msg.alert('Error', 'There are not enough rows in the text, there was an error parsing the excel file');
            return;
        }

        this.doParse(parsed);
    },

    doParse: function(parsed)
    {
        var errors = [];

        var recordMap = {
            primaryheader: [],
        };

        Ext4.Msg.wait('Please be patient while we Process your data...');

        var chargetype = 'Infectious Disease Resource';   //Same Charge unit

        var offset = 2;
        var rowIdx = offset;
        for (var i = offset; i < parsed.length; i++)
        {
            rowIdx++;
            var row = parsed[i];
            if (!row || row.length < 2)
            {
                errors.push('Row ' + rowIdx + ': not enough items in row');
                continue;
            }
            var date = parsed[i][0];
            if (!date)
            {
                errors.push('Row ' + rowIdx + ': missing date');
                return;
            }


            var cnt = i;

            this.processRow(row, recordMap, errors, rowIdx, id, parsed, cnt,chargetype);
        }

        Ext4.Msg.hide();

        if (errors.length)
        {
            errors = Ext4.unique(errors);
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }
        //Main Header
        if (recordMap.primaryheader.length)
        {
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('miscCharges');
            LDK.Assert.assertNotEmpty('Unable to find procedure store in Misc Charges', clientStore);

            var records = [];
            for (var i = 0; i < recordMap.primaryheader.length; i++)
            {
                records.push(clientStore.createModel(recordMap.primaryheader[i]));
            }

            clientStore.add(records);
        }


        this.close();
    },

    processRow: function(row, recordMap, errors, rowIdx,tdate, parsed, cnt,chargetype)
    {

        var date = LDK.ConvertUtils.parseDate(this.safeGet(parsed, cnt, 0));
        if (!date)
        {
            errors.push('Missing Date');
        }


        // var project = this.resolveProjectByName(Ext4.String.trim(row[14]), errors, rowIdx);

            var HeaderObjectID = LABKEY.Utils.generateUUID().toUpperCase();
            // var project = this.resolveProjectByName(Ext4.String.trim(parsed[1][1]), errors,rowIdx );
            var value = Ext4.String.trim(row[3]);    //Chargeid
            var chargeid = value.split(',');

            var tvalue = Ext4.String.trim(row[1]);    //project
            var project = tvalue.split(',');
            var finalchargeid = Math.floor(chargeid[0]);

            var obj = {
                date: date,
                project:project[0],
                chargetype: chargetype,
                quantity: Ext4.String.trim(row[4]),
                chargeid: finalchargeid,
                objectid: HeaderObjectID


            };

            if (!this.checkRequired(['date', 'project','chargetype','chargeid','objectid'], obj, errors, rowIdx))
            {
                recordMap.primaryheader.push(obj);
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

        return   hasErrors;
    },

    getTime: function(date, timeStr, errors, rowIdx){
        if (!date || !timeStr){
            return null;
        }

        var orig = date;
        date = LDK.ConvertUtils.parseDate(date);
        if (!date){
            errors.push('Row ' + rowIdx + ': invalid date format: ' + orig);
            return null;
        }

        timeStr = Ext4.String.leftPad(timeStr, 5, '0'); //expect: HH:mm
        var ret = LDK.ConvertUtils.parseDate(Ext4.Date.format(date, LABKEY.extDefaultDateFormat) + ' ' + timeStr);
        if (!ret){
            errors.push('Row ' + rowIdx + ': invalid time: ' + timeStr);
        }

        return ret;
    },

    resolveProjectByName: function(projectName, errors, rowIdx){
        if (!projectName){
            return null;
        }

        projectName = Ext4.String.trim(projectName);
        var ret = EHR.DataEntryUtils.resolveProjectByName(this.projectStore, projectName);
        if (!ret){
            errors.push('Row ' + rowIdx + ': unknown project ' + projectName);
        }
        else {
            return ret;
        }
    },

    safeGet: function(parsed, a, b){
        if (parsed && parsed.length >= a && parsed[a].length >= b){
            return parsed[a][b];
        }
        else {
            console.error('Unable to find position: ' + a + '/' + b);
        }
    }
});

EHR.DataEntryUtils.registerDataEntryFormButton('MISC_SCAN_IMPORT', {
    text: 'Misc Charges Bulk Data Import',
    name: 'miscChargesscan',
    itemId: 'miscChargesscan',
    tooltip: 'Click to import using Misc Charges Bulk Import template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in Misc Charges Panel button', panel);

        Ext4.create('ONPRC_EHR.window.MiscCharges_ScanWindow', {
            dataEntryPanel: panel
        }).show();
    }
});
