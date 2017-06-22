/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel      Created 2/18/2015    Blasa    Serology Entries
 */
// Note:  This progam processes bulk entries related to SPF Template  5-4-2015

Ext4.define('ONPRC_EHR.window.BulkSerology_VirologyWindow', {
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
                html : 'This allows you to import record using the SPF_Template excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/SPF_Template.xlsx'
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
            primaryheader: [],
            labresults: []

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
            var id = parsed[i][0];
            if (!id)
            {
                errors.push('Row ' + rowIdx + ': missing Id');
                return;
            }

            var cnt = i;

            if ( Ext4.String.trim(row[3])== 1)
            {
                MasterHeaderObject = LABKEY.Utils.generateUUID().toUpperCase();
            }


            this.processRow(row, recordMap, errors, rowIdx, id, parsed, cnt, MasterHeaderObject);
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

    processRow: function(row, recordMap, errors, rowIdx,id, parsed, cnt,MasterHeaderObject)
    {

        // Generate labwork Header information
        var performedBy = Ext4.String.trim(row[13]);
        var date = LDK.ConvertUtils.parseDate(this.safeGet(parsed, cnt, 1));
        if (!date)
        {
            errors.push('Missing Date');
        }
        //var project = this.resolveProjectByName(Ext4.String.trim(row[2]), errors, rowIdx);
        var project = this.resolveProjectByName(row[2], errors, rowIdx);
        var chargeunit = Ext4.String.trim(row[5]);

        var name = Ext4.String.trim(row[4]);
        var procRecIdx = this.labworkSericeStoreStore.findExact('servicename', name);
        var procedureRec = this.labworkSericeStoreStore.getAt(procRecIdx);
        LDK.Assert.assertNotEmpty('Unable to find service request record with name: ' + name + 'in Serology_VirologyWindow', procedureRec);
        var servicereq = procedureRec.get('servicename');

        var category = Ext4.String.trim(row[14]);


        if ( Ext4.String.trim(row[3])== 1)
        {
            var tissueheader = "";
            if (row[0] && row[0].length >= 5) {
                tissueheader = Ext4.String.trim(row[6].substr(row[6].length - 7, 7));
             }
            var obj = {
                Id: id,
                date: date,
                project: project,
                servicerequested: servicereq,
                chargeunit: chargeunit,
                tissue: tissueheader,       // Tissue for main header    -- Optional
                type: category,
                objectid: MasterHeaderObject,
                performedby: performedBy

            };

        if (!this.checkRequired(['Id', 'date', 'project', 'chargeunit', 'servicerequested', 'type'], obj, errors, rowIdx))
             {
            recordMap.primaryheader.push(obj);
            }
        };
        // Generate Labwork Panel Details

        //Tissue Results
        if (row[7])
        {
            var Resultsobjectid = LABKEY.Utils.generateUUID().toUpperCase();


            var obj = {
                Id: id,
                date: date,
                tissue: Ext4.String.trim(row[7].substr(row[7].length - 7, 7)),       // Tissue Results
                agent:  Ext4.String.trim(row[8].substr(row[8].length - 7, 7)),
                method: Ext4.String.trim(row[9]),
                result: Ext4.String.trim(row[10]),
                qualifier: Ext4.String.trim(row[11]),
                remark: Ext4.String.trim(row[12]),
                objectid: Resultsobjectid,
                runid: MasterHeaderObject,
                performedby: performedBy

            };

            // labwork Panel-Details information
            if (!this.checkRequired(['Id', 'date' ,'tissue','agent','method', 'result'],obj,errors, rowIdx))
            {
                recordMap.labresults.push(obj);
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

EHR.DataEntryUtils.registerDataEntryFormButton('SEROLOGY_IMPORT', {
    text: 'SPF Template Import',
    name: 'serologyimp',
    itemId: 'serologyimp',
    tooltip: 'Click to import using a Serology Virology excel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in SPF Template Import button', panel);

        Ext4.create('ONPRC_EHR.window.BulkSerology_VirologyWindow', {
            dataEntryPanel: panel
        }).show();
    }
});