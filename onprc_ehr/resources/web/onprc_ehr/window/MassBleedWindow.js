/*
 * Copyright (c) 2014-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel
 */
Ext4.define('ONPRC_EHR.window.MassBleedWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'DCM Processing/Mass Bleed Import',
            bodyStyle: 'padding: 5px;',
            width: 800,
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import record using the DCM Mass Bleed excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/DCM Mass Processing Form.xlsx'
                }
            },{
                xtype: 'labkey-combo',
                allowBlank: false,
                displayField: 'chargetype',
                fieldLabel: 'Charge Unit',
                width: 450,
                valueField: 'chargetype',
                itemId: 'chargetypeField',
                queryMode: 'local',
                store: {
                    type: 'labkey-store',
                    schemaName: 'onprc_billing_public',
                    queryName: 'chargeUnits',
                    autoLoad: true
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

        var chargeType = this.down('#chargetypeField').getValue();
        if (!chargeType){
            Ext4.Msg.alert('Error', 'Must enter the Charge Unit');
            return;
        }

        var parsed = LDK.Utils.CSVToArray(Ext4.String.trim(text), '\t');
        if (!parsed){
            Ext4.Msg.alert('Error', 'There was an error parsing the excel file');
            return;
        }

        if (parsed.length < 9){
            Ext4.Msg.alert('Error', 'There are not enough rows in the text, there was an error parsing the excel file');
            return;
        }

        this.doParse(parsed);
    },

    doParse: function(parsed){
        var errors = [];

        //first get global values:
        var chargeType = this.down('#chargetypeField').getValue();
        var date = LDK.ConvertUtils.parseDate(this.safeGet(parsed, 1, 0));
        if (!date){
            errors.push('Missing Date');
        }

        var performedBy = this.safeGet(parsed, 3, 0);
        if (!performedBy){
            errors.push('Missing Performed');
        }

        if (errors.length){
            errors = Ext4.unique(errors);
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }

        var projects = parsed[7];
        var times = parsed[8];

        var recordMap = {
            blood: [],
            weight: [],
            drug: [],
            encounters: []
        };

        Ext4.Msg.wait('Processing...');

        var offset = 9;
        var rowIdx = offset; //report rowIdx including the header rows
        for (var i=offset;i<parsed.length;i++){
            rowIdx++;
            var row = parsed[i];
            if (!row || row.length < 10){
                errors.push('Row ' + rowIdx + ': not enough items in row');
                continue;
            }

            this.processRow(row, recordMap, date, chargeType, performedBy, projects, times, errors, rowIdx);
        }

        Ext4.Msg.hide();

        if (errors.length){
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }

        //weight
        if (recordMap.weight.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Weight');
            LDK.Assert.assertNotEmpty('Unable to find weight store in MassBleedWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.weight.length;i++){
                records.push(clientStore.createModel(recordMap.weight[i]));
            }

            clientStore.add(records);
        }

        //blood
        if (recordMap.blood.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('blood');
            LDK.Assert.assertNotEmpty('Unable to find blood store in MassBleedWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.blood.length;i++){
                records.push(clientStore.createModel(recordMap.blood[i]));
            }

            clientStore.add(records);
        }

        //drug
        if (recordMap.drug.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Drug Administration');
            LDK.Assert.assertNotEmpty('Unable to find Drug Administration store in MassBleedWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.drug.length;i++){
                records.push(clientStore.createModel(recordMap.drug[i]));
            }

            clientStore.add(records);
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

        this.close();
    },

    processRow: function(row, recordMap, date, chargeType, performedBy, projects, times, errors, rowIdx){
        var id = row[0];
        if (!id){
            errors.push('Row ' + rowIdx + ': missing Id');
            return;
        }

        //blood columns first
        for (var i=2;i<9;i++){
            if (row[i]){
                var obj = {
                    Id: id,
                    date: this.getTime(date, times[i], errors, rowIdx),
                    chargetype: chargeType,
                    project: this.resolveProjectByName(projects[i], errors, rowIdx),
                    performedby: performedBy,
                    tube_type: 'Other',
                    quantity: row[i]
                };

               // obj.reason = ['0492', '0492-01'].indexOf(obj.project) == -1 ? 'Research' : 'Clinical'
                // Updarted 2-25-2015 Blasa
                obj.reason = ['0492', '0492-01'].indexOf(obj.project) == -1 ? 'Clinical' : 'Research';

                if (!this.checkRequired(['Id', 'date', 'project', 'quantity'], obj, errors, rowIdx)){
                    recordMap.blood.push(obj);
                }
            }
        }

        //weight
        if (row[9]){
            var obj = {
                Id: id,
                date: this.getTime(date, times[9], errors, rowIdx),
                performedby: performedBy,
                weight: row[9]
            };

            if (!this.checkRequired(['Id', 'date', 'weight'], obj, errors, rowIdx)){
                recordMap.weight.push(obj);
            }
        }

        //ivermectin
        if (row[10]){
            //also require a weight, which is used to guess dose
            var weight = row[9];
            if (!weight){
                errors.push('Row ' + rowIdx + ': must enter a weight if ivermectin is selected');
            }
            else {
                var amount = EHR.Utils.roundToNearest((weight), 1);
                var volume = EHR.Utils.roundToNearest((weight * 0.1), 0.1);

                var obj = {
                    Id: id,
                    date: this.getTime(date, times[10], errors, rowIdx),
                    chargetype: chargeType,
                    project: EHR.DataEntryUtils.getDefaultClinicalProject(),
                    performedby: performedBy,
                    route: 'SQ',
                    amount: amount,
                    amount_units: 'mg',
                    volume: volume,
                    vol_units: 'mL',
                    code: 'E-Y7410'  //ivermectin
                };

                if (!this.checkRequired(['Id', 'date', 'amount'], obj, errors, rowIdx)){
                    recordMap.drug.push(obj);
                }
            }
        }

        //TB
        if (row[11]){
            var obj = {
                Id: id,
                date: this.getTime(date, times[11], errors, rowIdx),
                project: EHR.DataEntryUtils.getDefaultClinicalProject(),
                chargetype: chargeType,
                performedby: performedBy
            };

            if (!LABKEY.ext4.Util.hasStoreLoaded(this.procedureStore)){
                //TODO
            }

            var name;
            if (row[11].match('Intradermal')){
                name = 'TB Test Intradermal';
            }
            else if (row[11].match('Serological')){
                name = 'TB Test Serologic';
            }
            else {
                errors.push('Row ' + rowIdx + ': unknown value for TB column: ' + row[11]);
            }

            var procRecIdx = this.procedureStore.findExact('name', name);
            var procedureRec = this.procedureStore.getAt(procRecIdx);
            LDK.Assert.assertNotEmpty('Unable to find procedure record with name: ' + name + 'in MassBloodWindow', procedureRec);
            obj.procedureid = procedureRec.get('rowid');

            if (!this.checkRequired(['Id', 'date', 'procedureid'], obj, errors, rowIdx)){
                recordMap.encounters.push(obj);
            }
        }

        //Tattoo
        if (row[12]){
            var obj = {
                Id: id,
                date: this.getTime(date, times[12], errors, rowIdx),
                project: EHR.DataEntryUtils.getDefaultClinicalProject(),
                chargetype: chargeType,
                performedby: row[12]
            };

            var name = 'Tattoo';
            var procRecIdx = this.procedureStore.findExact('name', name);
            var procedureRec = this.procedureStore.getAt(procRecIdx);
            LDK.Assert.assertNotEmpty('Unable to find procedure record with name: ' + name + 'in MassBloodWindow', procedureRec);
            obj.procedureid = procedureRec.get('rowid');

            if (!this.checkRequired(['Id', 'date', 'procedureid'], obj, errors, rowIdx)){
                recordMap.encounters.push(obj);
            }
        }

        //sedation
        if (row[13]){
            var obj = {
                Id: id,
                date: this.getTime(date, times[13], errors, rowIdx),
                project: EHR.DataEntryUtils.getDefaultClinicalProject(),
                chargetype: chargeType,
                performedby: performedBy,
                amount_units: 'mg',
                amount: row[14],
                route: row[15]
            };

            //complications
            if (row[16] && row[16].match(/Complication/)){
                obj.outcome = 'Abnormal';
            }
            else {
                obj.outcome = 'Normal';
            }

            //complication/remark
            if (row[17]){
                obj.remark = row[17];
            }

            //code:
            var code = row[13].split(/\r?\n/);
            if (code.length != 2){
                errors.push('Row ' + rowIdx + ': invalid sedation drug: ' + row[13]);
            }
            else {
                obj.code = code[1];

                if (!this.checkRequired(['Id', 'date', 'code', 'amount', 'route'], obj, errors, rowIdx)){
                    recordMap.drug.push(obj);
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

        return hasErrors;
    },

    getTime: function(date, timeStr, errors, rowIdx){
        if (!date || !timeStr){
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

EHR.DataEntryUtils.registerDataEntryFormButton('MASS_BLEED', {
    text: 'DCM Mass Bleed Form',
    name: 'massbleed',
    itemId: 'massbleed',
    tooltip: 'Click to import using the DCM Mass Bleed excel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in MASS_BLEED button', panel);

        Ext4.create('ONPRC_EHR.window.MassBleedWindow', {
            dataEntryPanel: panel
        }).show();
    }
});