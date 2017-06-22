/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel      Created 4/6/2015    Blasa    Serology Scan Entries
 */
Ext4.define('ONPRC_EHR.window.BulkSerologyScanWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Serology Virology Import',
            bodyStyle: 'padding: 5px;',
            width: 800,
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import record using the Serology Intuitive Excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/Intuitive_Template.xlsx'
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

    doParse: function(parsed)
    {
        var errors = [];

        var recordMap = {
            primaryheader: [],
            labresults: []

        };

        Ext4.Msg.wait('Please be patient while we Process your data...');
        var category = parsed[0][1]  ;
        var Technician = parsed[1][1]  ;
        var chargeunit = parsed[2][1]  ;
        var TissueMain =   Ext4.String.trim(parsed[3][1].substr(parsed[3][1].length - 7, 7));
        var method =   Ext4.String.trim(parsed[4][1] )  ;

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

            var id = parsed[i][1];
            if (!id)
            {
                errors.push('Row ' + rowIdx + ': missing Id');
                return;
            }

            var cnt = i;

            this.processRow(row, recordMap, errors, rowIdx, id, parsed, cnt,category,Technician,chargeunit,TissueMain,method);
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
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Clinpath Runs');
            LDK.Assert.assertNotEmpty('Unable to find procedure store in ClinpathRuns', clientStore);

            var records = [];
            for (var i = 0; i < recordMap.primaryheader.length; i++)
            {
                records.push(clientStore.createModel(recordMap.primaryheader[i]));
            }

            clientStore.add(records);
        }


        //Lab Results
        if (recordMap.labresults.length)
        {
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('serology');
            LDK.Assert.assertNotEmpty('Unable to find observation store in serology', clientStore);

            var records = [];
            for (var i = 0; i < recordMap.labresults.length; i++)
            {
                records.push(clientStore.createModel(recordMap.labresults[i]));
            }

            clientStore.add(records);
        }


        this.close();
    },

    processRow: function(row, recordMap, errors, rowIdx,id, parsed, cnt,category,Technician,chargeunit,TissueMain,method)
    {

        // Generate labwork Header information

        var date = LDK.ConvertUtils.parseDate(this.safeGet(parsed, cnt, 0));
        if (!date)
        {
            errors.push('Missing Date');
        }
        //var project = this.resolveProjectByName(Ext4.String.trim(row[2]), errors, rowIdx);


        var project = this.resolveProjectByName(Ext4.String.trim(row[13]), errors, rowIdx);
        var name = Ext4.String.trim(row[14]);
        var procRecIdx = this.labworkSericeStoreStore.findExact('servicename', name);
        var procedureRec = this.labworkSericeStoreStore.getAt(procRecIdx);
        LDK.Assert.assertNotEmpty('Unable to find service request record with name: ' + name + 'in Serology_VirologyWindow', procedureRec);
        var servicereq = procedureRec.get('servicename');





        // Generate Labwork Panel Details
        var FirstTimeFlag = 1;         //set flag

        for (var k = 2; k < 12; k++)         // Process only if Agent data exists
        {

            //Tissue Results
            if (row[k])
            {
                if (FirstTimeFlag == 1)
                    {
                        var HeaderObjectID = LABKEY.Utils.generateUUID().toUpperCase();

                        var obj = {
                            Id: id,
                            date: date,
                            project: project,
                            servicerequested: servicereq,
                            chargeunit: chargeunit,
                            tissue: TissueMain,       // Tissue for main header    -- Optional
                            type: category,
                            objectid: HeaderObjectID,
                            performedby: Technician

                        };

                        if (!this.checkRequired(['Id', 'date', 'project', 'chargeunit', 'servicerequested', 'type'], obj, errors, rowIdx))
                        {
                            recordMap.primaryheader.push(obj);
                        }
                        FirstTimeFlag = 0;   //Reset after the first entry
                }

                var Resultsobjectid = LABKEY.Utils.generateUUID().toUpperCase();

                var obj = {
                    Id: id,
                    date: date,
                    tissue: Ext4.String.trim(row[16].substr(row[16].length - 7, 7)),       // Tissue Results
                    agent: Ext4.String.trim(parsed[5][k].substr(parsed[5][k].length - 7, 7)),
                    method: method,
                    result: Ext4.String.trim(row[k]),
                    qualifier: Ext4.String.trim(row[15]),
                    remark: Ext4.String.trim(row[12]),
                    objectid: Resultsobjectid,
                    runid: HeaderObjectID,
                    performedby: Technician

                };

                // labwork Panel-Details information
                if (!this.checkRequired(['Id', 'date', 'tissue', 'method', 'result'], obj, errors, rowIdx))
                {
                    recordMap.labresults.push(obj);
                }


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
        var ret = LDK.ConvertUtils.parseDate(date.format(LABKEY.extDefaultDateFormat) + ' ' + timeStr);
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

EHR.DataEntryUtils.registerDataEntryFormButton('SEROLOGY_SCAN_IMPORT', {
    text: 'Intuitive Panel Import',
    name: 'serologyscan',
    itemId: 'serologyscan',
    tooltip: 'Click to import using a Serology Intuitive Panel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in Intuitive_Import button', panel);

        Ext4.create('ONPRC_EHR.window.BulkSerologyScanWindow', {
            dataEntryPanel: panel
        }).show();
    }
});