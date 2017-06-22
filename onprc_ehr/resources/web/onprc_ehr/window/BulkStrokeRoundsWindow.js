/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel
 * Created 11/21/2014 Blasa Bulk Observation Entries
 */
Ext4.define('ONPRC_EHR.window.BulkStrokeRoundsWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'MCA Occlusion Import',
            bodyStyle: 'padding: 5px;',
            width: 800,
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import record using the MCA Occlusion Stroke Rounds excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/MCA Occlusion Stroke Rounds.xlsx'
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
        this.procedureStore = EHR.DataEntryUtils.getProceduresStore();

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

        if (parsed.length < 8){
            Ext4.Msg.alert('Error', 'There are not enough rows in the text, there was an error parsing the excel file');
            return;
        }

        this.doParse(parsed);
    },

    doParse: function(parsed){
        var errors = [];

        var recordMap = {
            encounters: [],
            score: [],
            soaps: []

        };

        Ext4.Msg.wait('Please be patient while we Process your data...');

        var offset = 8;
        var rowIdx = offset;
        for (var i=offset;i<parsed.length;i++){
            rowIdx++;
            var row = parsed[i];
            if (!row || row.length < 7){
                errors.push('Row ' + rowIdx + ': not enough items in row');
                continue;
            }
            var id = parsed[0][1];
            if (!id){
                errors.push('Row ' + rowIdx + ': missing Id');
                return;
            }
            var procedure = parsed[5][1];
            var narrative = parsed[6][1];
            //var project = this.resolveProjectByName(parsed[4][1], errors, rowIdx);
            var project = EHR.DataEntryUtils.getDefaultClinicalProject();
            var cnt = i;

            this.processRow(row, recordMap, errors, rowIdx, procedure, narrative,project, id, parsed,cnt);
        }

        Ext4.Msg.hide();

        if (errors.length){
            errors = Ext4.unique(errors);
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }
        //Procedure
        if (recordMap.encounters.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('encounters');
            LDK.Assert.assertNotEmpty('Unable to find procedure store in BulkStrokeRoundsWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.encounters.length;i++){
                records.push(clientStore.createModel(recordMap.encounters[i]));
            }

            clientStore.add(records);
        }


        //Observation
        if (recordMap.score.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Clinical Observations');
            LDK.Assert.assertNotEmpty('Unable to find observation store in BulkStrokeRoundsWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.score.length;i++){
                records.push(clientStore.createModel(recordMap.score[i]));
            }

            clientStore.add(records);
        }

        //soap
        if (recordMap.soaps.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Clinical Remarks');
            LDK.Assert.assertNotEmpty('Unable to find soap store in BulkStrokeRoundsWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.soaps.length;i++){
                records.push(clientStore.createModel(recordMap.soaps[i]));
            }

            clientStore.add(records);
        }


        this.close();
    },

    processRow: function(row, recordMap, errors, rowIdx, procedure, narrative,project, id, parsed, cnt){

        var performedBy = row[0];
        var date = LDK.ConvertUtils.parseDate(this.safeGet(parsed,cnt,1));
        if (!date){
            errors.push('Missing Date');
        }


        var date = this.getTime(date, row[2], errors, rowIdx);

        //Procedures
        if (row[5]){
            var obj = {
                Id: id,
                date: date,
                project:project ,
                chargeunit:'No Charge',
               // procedure: procedure,
                remark: narrative,  // Procedure Narative
                performedby: performedBy

            };
            var name = procedure;
            var procRecIdx = this.procedureStore.findExact('name', name);
            var procedureRec = this.procedureStore.getAt(procRecIdx);
            LDK.Assert.assertNotEmpty('Unable to find procedure record with name: ' + name + 'in StrokeRoundsWindow', procedureRec);
            obj.procedureid = procedureRec.get('rowid');
            if (!this.checkRequired(['Id', 'date', 'procedureid','remark'], obj, errors, rowIdx)){
                recordMap.encounters.push(obj);
            }
        }


        //observations  -Att
        if (row[4]){
            var obj = {
                Id: id,
                date: date,
                category: Ext4.String.trim(parsed[7][4]),
                area:'N/A',
                observation: Ext4.String.trim(row[4]),
                performedby: performedBy

            };

            if (!this.checkRequired(['Id', 'date', 'category', 'observation','performedby'], obj, errors, rowIdx)){
                recordMap.score.push(obj);
            }
        }

        //observations -App
        if (row[5]){
            var obj = {
                Id: Ext4.String.trim(id),
                date: date,
                category: Ext4.String.trim(parsed[7][5]),
                area:'N/A',
                observation: Ext4.String.trim(row[5]),
                performedby: performedBy

            };

            if (!this.checkRequired(['Id', 'date', 'category', 'observation','performedby'], obj, errors, rowIdx)){
                recordMap.score.push(obj);
            }
        }

        //observations -Stool
        if (row[6]){
            var obj = {
                Id: Ext4.String.trim(id),
                date: date,
                category: Ext4.String.trim(parsed[7][6]),
                area:'N/A',
                observation: Ext4.String.trim(row[6]),
                performedby: performedBy

            };

            if (!this.checkRequired(['Id', 'date', 'category', 'observation','performedby'], obj, errors, rowIdx)){
                recordMap.score.push(obj);
            }
        }

        //observations - Pain Score
        if (row[7]){

            var obj = {
                Id: Ext4.String.trim(id),
                date: date,
                category: Ext4.String.trim(parsed[7][7]),
                area:'N/A',
                observation: Ext4.String.trim(row[7]),
                performedby: performedBy

            };

            if (!this.checkRequired(['Id', 'date', 'category', 'observation','performedby'], obj, errors, rowIdx)){
                recordMap.score.push(obj);
            }
        }
        //observations - Incision
        if (row[8]){

            var obj = {
                Id: Ext4.String.trim(id),
                date: date,
                category: Ext4.String.trim(parsed[7][8]),
                area:'N/A',
                observation: Ext4.String.trim(row[8]),
                remark: Ext4.String.trim(row[9]),  //Remarks Only appears on Incisions
                performedby: performedBy

            };

            if (!this.checkRequired(['Id', 'date', 'category', 'observation','performedby'], obj, errors, rowIdx)){
                recordMap.score.push(obj);
            }
        }

        //soap
        if (row[10]){
            var obj = {
                Id: id,
                date: date,
                a: Ext4.String.trim(row[10]),
                performedby: performedBy

            };

            if (!this.checkRequired(['Id', 'date', 'a','performedby'], obj, errors, rowIdx)){
                recordMap.soaps.push(obj);
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

        return hasErrors;
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

EHR.DataEntryUtils.registerDataEntryFormButton('STROKE_ROUNDS', {
    text: 'MCA Occlusion Stroke Rounds Form',
    name: 'strokerounds',
    itemId: 'strokerounds',
    tooltip: 'Click to import using a MCA Occlusion Stroke Rounds excel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in STROKE_ROUNDS button', panel);

        Ext4.create('ONPRC_EHR.window.BulkStrokeRoundsWindow', {
            dataEntryPanel: panel
        }).show();
    }
});