/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel
 */
// Created 5-25-2021  Blasa    Bulk Clinical Screen Mass processing

Ext4.define('ONPRC_EHR.window.ClinicalProcessingWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Clinical Processing Import',
            bodyStyle: 'padding: 5px;',
            width: 800,
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import record using the Clinical Processing Template excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/ClinicalProcessingTemplate.xlsx'
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
            Ext4.Msg.alert('Error', 'Must paste the records into the text area');
            return;
        }
        var MasterHeaderObject = "";

        var parsed = LDK.Utils.CSVToArray(Ext4.String.trim(text), '\t');
        if (!parsed){
            Ext4.Msg.alert('Error', 'There was an error parsing the excel file');
            return;
        }

        if (parsed.length < 4){
            Ext4.Msg.alert('Error', 'There are not enough rows in the text, there was an error parsing the excel file');
            return;
        }

        this.doParse(parsed);
    },

    doParse: function(parsed)
    {
        var errors = [];

        var recordMap = {
            soap: [],
            observations: [],
            diagnosticcodes: [],
            encounters: []
        };


        Ext4.Msg.wait('Please be patient while we Process your data...');

        var offset = 67;
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

            var chargeunit = this.safeGet(parsed, 11, 1);
            var date = LDK.ConvertUtils.parseDate(this.safeGet(parsed, 2, 1));
            if (!date){
                errors.push('Missing Date');
            }

            var performedBy = this.safeGet(parsed, 4, 2);   // same as Assigned Vet
            if (!performedBy){
                errors.push('Missing Performed');
            }

            if (errors.length){
                errors = Ext4.unique(errors);
                Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
                return;
            }

            var projects = this.resolveProjectByName(Ext4.String.trim(this.safeGet(parsed, 10, 1)));
            var times = this.safeGet(parsed, 2, 2);


            //  Procedure name
            var name = Ext4.String.trim(this.safeGet(parsed, 12, 1));
            var procRecIdx = this.procedureStore.findExact('name', name);
            var procedureRec = this.procedureStore.getAt(procRecIdx);
            LDK.Assert.assertNotEmpty('Unable to find procedure record with name: ' + name + 'in Clinical Processing Window', procedureRec);


            this.processRow(row, recordMap, errors, rowIdx, chargeunit, date, projects,times,parsed, performedBy, procedureRec);
        }

        Ext4.Msg.hide();

        if (errors.length)
        {
            errors = Ext4.unique(errors);
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }


        //procedures
        if (recordMap.encounters.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('encounters');
            LDK.Assert.assertNotEmpty('Unable to find encounters store in MassBleedWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.encounters.length;i++){
                records.push(clientStore.createModel(recordMap.encounters[i]));
            }

            clientStore.add(records);
        }

        //soap
        if (recordMap.soap.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Clinical Remarks');
            LDK.Assert.assertNotEmpty('Unable to find clinical remarks store in Clinical Processing Window', clientStore);

            var records = [];
            for (var i=0;i<recordMap.soap.length;i++){
                records.push(clientStore.createModel(recordMap.soap[i]));
            }

            clientStore.add(records);
        }

        //diagnostic codes
        if (recordMap.diagnosticcodes.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('snomed_tags');
            LDK.Assert.assertNotEmpty('Unable to find EHR Snomed Tags store in Clinical Processing Window', clientStore);

            var records = [];
            for (var i=0;i<recordMap.diagnosticcodes.length;i++){
                records.push(clientStore.createModel(recordMap.diagnosticcodes[i]));
            }

            clientStore.add(records);
        }

        //  Clinical Observations
        if (recordMap.observations.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Clinical Observations');
            LDK.Assert.assertNotEmpty('Unable to find clinical observations store in Clinical Processing Window', clientStore);

            var records = [];
            for (var i=0;i<recordMap.observations.length;i++){
                records.push(clientStore.createModel(recordMap.observations[i]));
            }

            clientStore.add(records);
        }

        this.close();
    },

    processRow: function(row, recordMap, errors, rowIdx, chargeunit, date, projects,times,parsed, performedBy, procedureRec)
    {
        var id = row[0];
        if (!id){
            errors.push('Row ' + rowIdx + ': missing Id');
            return;
        }


        if (row[0] && row[4])
        {
            var obj = {
                Id: id,
                date: this.getTime(date, times, errors, rowIdx),
                project: projects,
                procedureid: procedureRec.get('rowid'),
                chargetype: chargeunit,
                performedby: performedBy

            };

            if (!this.checkRequired(['Id', 'date', 'project', 'chargetype', 'procedureid','performedby'], obj, errors, rowIdx))
            {
                recordMap.encounters.push(obj);
            }
        };


         if (row[4] && row[5] && row[6]){
            var obj = {
                Id: id,
                date: this.getTime(date, times, errors, rowIdx),
                category: this.safeGet(parsed, 48, 1),
                area: this.safeGet(parsed, 49, 1),
                observation:this.safeGet(parsed, 50, 1),  // Alopecia, BCS and REG values
                performedby: performedBy

            };
            // Observations  BCS only
            if (!this.checkRequired(['Id', 'date', 'category', 'area', 'observation','performedby'], obj, errors, rowIdx))
            {
                recordMap.observations.push(obj);
            }
        };

        if (row[4] && row[5]){
           var obj = {
            Id: id,
            date: this.getTime(date, times, errors, rowIdx),
            category: this.safeGet(parsed, 41, 1),
            area: this.safeGet(parsed, 42, 1),
            observation:Ext4.String.trim(row[5]) ,  // Alopecia score
            performedby: performedBy

        };

        if (!this.checkRequired(['Id', 'date', 'category', 'area', 'observation','performedby'], obj, errors, rowIdx))
        {
            recordMap.observations.push(obj);
        }
      };
        // BCS Only
        if (row[4]){
            var obj = {
                Id: id,
                date: this.getTime(date, times, errors, rowIdx),
                category: this.safeGet(parsed, 34, 1),
                area: this.safeGet(parsed, 35, 1),
                observation:Ext4.String.trim(row[4]) ,  // BCS score
                performedby: performedBy

            };

            if (!this.checkRequired(['Id', 'date', 'category', 'area', 'observation','performedby'], obj, errors, rowIdx))
            {
                recordMap.observations.push(obj);
            }
        };


        if (row[1] && row[4] && row[8] && (row[1]  == 'Female')){
            var obj = {
                Id: id,
                date: this.getTime(date, times, errors, rowIdx),
                code:'F-31920'

            };

            if (!this.checkRequired(['Id', 'date',  'code'], obj, errors, rowIdx))
            {
                recordMap.diagnosticcodes.push(obj);
            }
        };
        

        if (row[1] && row[4] && row[7] && (row[1]  == 'Female')){
            var snomedcode;
            if (row[7] == 1 )
            {snomedcode = 'F-31020'}
            if (row[7] == 2 )
            {snomedcode = 'F-31030'}
            if (row[7]== 3 )
            {snomedcode = 'F-31040'}
            var obj = {
                Id: id,
                date: this.getTime(date, times, errors, rowIdx),
                code: snomedcode

            };

            if (!this.checkRequired(['Id', 'date', 'code'], obj, errors, rowIdx))
            {
                recordMap.diagnosticcodes.push(obj);
            }
        };




        if (row[4] && !row[9]) {
            var obj = {
                Id: id,
                date: this.getTime(date, times, errors, rowIdx),
                s: this.safeGet(parsed, 20, 1),
                a: this.safeGet(parsed, 24, 1),
                p: this.safeGet(parsed, 25, 1),
                assignedVet: performedBy,
                performedby: performedBy      //Sane as entered by

            };

            if (!this.checkRequired(['Id', 'date', 's', 'a', 'p', 'assignedVet', 'performedby'], obj, errors, rowIdx)) {
                recordMap.soap.push(obj);
            }
        }

         else   if (row[4] && row[9]) {
                var obj = {
                    Id: id,
                    date: this.getTime(date, times, errors, rowIdx),
                    s: this.safeGet(parsed, 20, 1),
                    p: this.safeGet(parsed, 25, 1),
                    o:row[9],
                    assignedVet: performedBy,
                    performedby: performedBy

                };


                if (!this.checkRequired(['Id', 'date', 's','o', 'p', 'assignedVet','performedby'], obj, errors, rowIdx)) {
                    recordMap.soap.push(obj);
                }

            };

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

EHR.DataEntryUtils.registerDataEntryFormButton('CLINICPROC_IMPORT', {
    text: 'Clinical Processing Template',
    name: 'clinicprocimp',
    itemId: 'clinicprocimp',
    tooltip: 'Click to import using a Clinical Processing excel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in Clinical Processing Import button', panel);

        Ext4.create('ONPRC_EHR.window.ClinicalProcessingWindow', {
            dataEntryPanel: panel
        }).show();
    }
});