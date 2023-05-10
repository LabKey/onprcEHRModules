/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel      Created 5-8-2023    Blasa    Path Tissues Scan Entries
 */
Ext4.define('ONPRC_EHR.window.PathTissueScanWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Path Tissue Import',
            bodyStyle: 'padding: 5px;',
            width: 800,
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import record using the Path Tissues Excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Tissue Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/PathTissue_Template.xlsx'
                }
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Recipient(s) Listings]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/Recipient_List.xlsx'
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
            Ext4.Msg.alert('Error', 'PLease paste your excel entries into the textarea');
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

    doParse: function(parsed)
    {
        var errors = [];

        var recordMap = {
            primaryheader: []

        };

        Ext4.Msg.wait('Please be patient while we Process your data...');

        var project = parsed[1][1]  ;
        var billingproject = parsed[2][1]  ;
        var recipient = parsed[3][1]  ;
        var animalid  = parsed[4][1]  ;
        var startdate  = parsed[5][1]  ;



        var offset = 6;
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


            var cnt = i;

            this.processRow(row, recordMap, errors, rowIdx, animalid, parsed, cnt,project,billingproject,recipient,startdate);
        }

        Ext4.Msg.hide();

        if (errors.length)
        {
            errors = Ext4.unique(errors);
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }

        if (recordMap.primaryheader.length)
        {
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('tissueDistributions');
            LDK.Assert.assertNotEmpty('Unable to find procedure store in Tissue Distribution', clientStore);

            var records = [];
            for (var i = 0; i < recordMap.primaryheader.length; i++)
            {
                records.push(clientStore.createModel(recordMap.primaryheader[i]));
            }

            clientStore.add(records);
        }

        this.close();
    },

    processRow: function(row, recordMap, errors, rowIdx,animalid, parsed, cnt,project,billingproject,recipient,startdate)
    {

        // validate the date entry

        var date = LDK.ConvertUtils.parseDate(startdate);



        var project = this.resolveProjectByName(Ext4.String.trim(billingproject));



            //Validate Tissue snomed entroies
            if (row[5])
            {

                    var HeaderObjectID = LABKEY.Utils.generateUUID().toUpperCase();

                    var obj = {
                        Id: animalid,
                        date: date,
                        project: project,
                        recipient: recipient,
                        remark:  Ext4.String.trim(parsed[cnt][3]),
                        tissue:  Ext4.String.trim(parsed[cnt][5]),
                        sampletype:  Ext4.String.trim(parsed[cnt][2]),
                        objectid: HeaderObjectID


                    };

                    if (!this.checkRequired(['Id', 'date', 'project', 'recipient', 'sampletype','tissue'], obj, errors, rowIdx))
                    {
                        recordMap.primaryheader.push(obj);
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

    resolveProjectByName: function(projectName){
        if (!projectName){
            return null;
        }

        projectName = Ext4.String.trim(projectName);
        var ret = EHR.DataEntryUtils.resolveProjectByName(this.projectStore, projectName);

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

EHR.DataEntryUtils.registerDataEntryFormButton('Tissues_SCAN_IMPORT', {
    text: 'Path Tissue Panel Import',
    name: 'tissuescan',
    itemId: 'tissuescan',
    tooltip: 'Click to import using a Path Tissues Panel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in PathTissue_Import button', panel);

        Ext4.create('ONPRC_EHR.window.PathTissueScanWindow', {
            dataEntryPanel: panel
        }).show();
    }
});
