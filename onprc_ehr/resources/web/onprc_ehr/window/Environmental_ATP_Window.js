/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */


// Created: 11-9-2023  R. Blasa

Ext4.define('ONPRC_EHR.window.Environmental_ATP_Window', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Environmental ATP Testing Import',
            bodyStyle: 'padding: 5px;',
            width: 800,
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import record using the ATP Testing excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/Env_ATP.xlsx'
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
        this.labworkSericeStoreStore = EHR.DataEntryUtils.getLabworkServicesStore();

        this.callParent(arguments);
    },

    onSubmit: function(){
        var text = this.down('#textField').getValue();
        if (!text){
            Ext4.Msg.alert('Error', 'Must paste the records into the text area');
            return;
        }
        var MasterHeaderObject = "";

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

    doParse: function(parsed)
    {
        var errors = [];

        var recordMap = {

            envresults: []

        };

        Ext4.Msg.wait('Please be patient while we Process your data...');

        var offset = 1;
        var rowIdx = offset;
        for (var i = offset; i < parsed.length; i++)
        {
            rowIdx++;
            var row = parsed[i];
            if (!row || row.length < 7)
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

            this.processRow(row, recordMap, errors, rowIdx, parsed, cnt);
        }

        Ext4.Msg.hide();

        if (errors.length)
        {
            errors = Ext4.unique(errors);
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }


        //ATP Results
        if (recordMap.envresults.length)
        {
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Environmental Assessment');
            LDK.Assert.assertNotEmpty('Unable to find Environmental Assessment', clientStore);

            var records = [];
            for (var i = 0; i < recordMap.envresults.length; i++)
            {
                records.push(clientStore.createModel(recordMap.envresults[i]));
            }

            clientStore.add(records);
        }


        this.close();
    },

    processRow: function(row, recordMap, errors, rowIdx,parsed, cnt)
    {

        // Generate labwork Header information
        var performedBy = LABKEY.Security.currentUser.id;
        var date = LDK.ConvertUtils.parseDate(this.safeGet(parsed, cnt, 1));
        if (!date)
        {
            errors.push('Missing Date');
        }

        var chargeunit = 'Kati';

        var servicereq = 'Sanitation: ATP';

        if (row[1])
        {
            var Resultsobjectid = LABKEY.Utils.generateUUID().toUpperCase();

            var obj = {

                date: date,
                service_requested: servicereq,
                chargeunit:chargeunit,
                test_location: Ext4.String.trim(row[2]),       // Area
                test_results:  Ext4.String.trim(row[3]),  //Lab Group
                action: Ext4.String.trim(row[4]),           //Room location
                surface_tested: Ext4.String.trim(row[5]),  //Surface Tested
                pass_fail: Ext4.String.trim(row[6]),      //Initial
                retest: Ext4.String.trim(row[7]),
                performedby: Ext4.String.trim(row[1]),     //Tech Initials
                objectid: Resultsobjectid,
                runid: MasterHeaderObject,
                performedby: performedBy


            };

            // labwork Panel-Details information
            if (!this.checkRequired([ 'date' ,'testlocation','test_results','action', 'surface_tested','pass_fail','retest'],obj,errors, rowIdx))
            {
                recordMap.envresults.push(obj);
            }

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


    safeGet: function(parsed, a, b){
        if (parsed && parsed.length >= a && parsed[a].length >= b){
            return parsed[a][b];
        }
        else {
            console.error('Unable to find position: ' + a + '/' + b);
        }
    }
});

EHR.DataEntryUtils.registerDataEntryFormButton('Env_ATP_IMPORT', {
    text: 'Environmental ATP Import',
    name: 'environementalimp',
    itemId: 'environmentalimp',
    tooltip: 'Click to import using a Serology Virology excel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in Environemtal Assessment ATP Import button', panel);

        Ext4.create('ONPRC_EHR.window.Enviromental_ATP_Window', {
            dataEntryPanel: panel
        }).show();
    }
});