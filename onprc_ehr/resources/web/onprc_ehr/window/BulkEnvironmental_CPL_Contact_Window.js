/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel      Created 4/29/2025   Blasa    Environmental CPL Entries
 */
Ext4.define('ONPRC_EHR.window.BulkEnvironmental_CPL_Contact_Window', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Bulk Environmental CPL Contact Import Window',
            bodyStyle: 'padding: 5px;',
            width: 800,
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import record using the Environmental_CPL_Contact Window Excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'

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

        var servicetype = 'Sanitation: Contact Plate';
        var chargeunit = 'Clinpath' ;


        var offset = 1;
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

            var tdate = parsed[i][1];
            if (!tdate)
            {
                errors.push('Row ' + rowIdx + ': missing date');
                return;
            }

            var cnt = i;

            this.processRow(row, recordMap, errors, rowIdx, parsed, cnt,servicetype,chargeunit);
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
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Environmental_Assessment');
            LDK.Assert.assertNotEmpty('Unable to find procedure store in Environmental_Assessment', clientStore);

            var records = [];
            for (var i = 0; i < recordMap.primaryheader.length; i++)
            {
                records.push(clientStore.createModel(recordMap.primaryheader[i]));
            }

            clientStore.add(records);
        }


        this.close();
    },

    processRow: function(row, recordMap, errors, rowIdx, parsed, cnt,servicetype,chargeunit) {

        // Generate Header information

        var HeaderObjectID = LABKEY.Utils.generateUUID().toUpperCase();

        var obj = {
            // date: date,
            service_requested: servicetype,
            charge_unit: chargeunit,
            testing_location: Ext4.String.trim(row[2]),  //Testing Location
            test_type: Ext4.String.trim(row[3]),  //Test Type
            test_method: Ext4.String.trim(row[4]) , // Method
            // pass_fail: Ext4.String.trim(row[6]), //Pass/Fail
            // action: Ext4.String.trim(row[7]),  // Action
            // retest: Ext4.String.trim(row[8]),  //Results Read by
            // colony_count: Ext4.String.trim(row[9]),  //Colony Count
            objectid: HeaderObjectID
            // performedby: Ext4.String.trim(row[10]),  //Collected by
            // remarks: Ext4.String.trim(row[11])       //Ccmments

         };

        if (!this.checkRequired([ 'service_requested','charge_unit','testing_location','test_type','test_method'], obj, errors, rowIdx))
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

EHR.DataEntryUtils.registerDataEntryFormButton('ENV_CPL_Contact_IMPORT', {
    text: 'Enviromental CPL Contact Import Window',
    name: 'envCPLContactscan',
    itemId: 'envCPLContactscan',
    tooltip: 'Click to import using a Environmental CPL Contact Panel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in Environmental CPL Contact Panel button', panel);

        Ext4.create('ONPRC_EHR.window.BulkEnvironmental_CPL_Contact_Window', {
            dataEntryPanel: panel
        }).show();
    }
});
