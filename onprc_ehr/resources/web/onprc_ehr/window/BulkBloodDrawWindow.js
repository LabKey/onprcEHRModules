/*
 * Copyright (c) 2014-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg dataEntryPanel
 */
Ext4.define('ONPRC_EHR.window.BulkBloodDrawWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Bulk Blood/Sedation Import',
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
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/Blood-Sedation Form.xlsx'
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

        if (parsed.length < 5){
            Ext4.Msg.alert('Error', 'There are not enough rows in the text, there was an error parsing the excel file');
            return;
        }

        this.doParse(parsed);
    },

    doParse: function(parsed){
        var errors = [];

        var recordMap = {
            blood: [],
            weight: [],
            drug: []
        };

        Ext4.Msg.wait('Processing...');

        var offset = 4;
        var rowIdx = offset;
        for (var i=offset;i<parsed.length;i++){
            rowIdx++;
            var row = parsed[i];
            if (!row || row.length < 7){
                errors.push('Row ' + rowIdx + ': not enough items in row');
                continue;
            }

            this.processRow(row, recordMap, errors, rowIdx);
        }

        Ext4.Msg.hide();

        if (errors.length){
            errors = Ext4.unique(errors);
            Ext4.Msg.alert('Error', 'There following errors were found:<p>' + errors.join('<br>'));
            return;
        }

        //weight
        if (recordMap.weight.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Weight');
            LDK.Assert.assertNotEmpty('Unable to find weight store in BulkBloodDrawWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.weight.length;i++){
                records.push(clientStore.createModel(recordMap.weight[i]));
            }

            clientStore.add(records);
        }

        //blood
        if (recordMap.blood.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('blood');
            LDK.Assert.assertNotEmpty('Unable to find blood store in BulkBloodDrawWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.blood.length;i++){
                records.push(clientStore.createModel(recordMap.blood[i]));
            }

            clientStore.add(records);
        }

        //drug
        if (recordMap.drug.length){
            var clientStore = this.dataEntryPanel.storeCollection.getClientStoreByName('Drug Administration');
            LDK.Assert.assertNotEmpty('Unable to find Drug Administration store in BulkBloodDrawWindow', clientStore);

            var records = [];
            for (var i=0;i<recordMap.drug.length;i++){
                records.push(clientStore.createModel(recordMap.drug[i]));
            }

            clientStore.add(records);
        }

        this.close();
    },

    processRow: function(row, recordMap, errors, rowIdx){
        var id = row[0];
        if (!id){
            errors.push('Row ' + rowIdx + ': missing Id');
            return;
        }

        var date = this.getTime(row[1], row[2], errors, rowIdx);
        var project = this.resolveProjectByName(row[3], errors, rowIdx);
        var chargeType = row[4];
        var performedBy = row[5];

        //blood first
        if (row[6]){
            var obj = {
                Id: id,
                date: date,
                project: project,
                chargetype: chargeType,
                performedby: performedBy,
                tube_type: 'Other',
                quantity: row[6]
            };

            if (!this.checkRequired(['Id', 'date', 'project', 'chargetype', 'performedby', 'quantity'], obj, errors, rowIdx)){
                recordMap.blood.push(obj);
            }
        }

        //weight
        if (row[7]){
            var obj = {
                Id: id,
                date: date,
                performedby: performedBy,
                weight: row[7]
            };

            if (!this.checkRequired(['Id', 'date', 'weight'], obj, errors, rowIdx)){
                recordMap.weight.push(obj);
            }
        }

        //sedation
        var baseObj = {
            Id: id,
            date: date,
            project: project,
            chargetype: chargeType,
            performedby: performedBy,
            amount_units: 'mg'
        };

        //ketamine
        this.processDrugRow(baseObj, 'E-70590', row, recordMap, errors, rowIdx, 8, 'IM', 11, 16);
        this.processDrugRow(baseObj, 'E-70590', row, recordMap, errors, rowIdx, 9, 'IV', 11, 16);
        this.processDrugRow(baseObj, 'E-70590', row, recordMap, errors, rowIdx, 10, 'PO', 11, 16);

        //telazol
        this.processDrugRow(baseObj, 'E-YY992', row, recordMap, errors, rowIdx, 12, 'IM', 15, 16);
        this.processDrugRow(baseObj, 'E-YY992', row, recordMap, errors, rowIdx, 13, 'IV', 15, 16);
        this.processDrugRow(baseObj, 'E-YY992', row, recordMap, errors, rowIdx, 14, 'PO', 15, 16);
    },

    processDrugRow: function(baseObj, code, row, recordMap, errors, rowIdx, amountIdx, route, complicationIdx, remarkIdx){
        if (row[amountIdx]){
            var obj = Ext4.apply({
                amount: row[amountIdx],
                route: route,
                code: code
            }, baseObj);

            //complications
            if (row[complicationIdx] && row[complicationIdx].match(/Complication/)){
                obj.outcome = 'Abnormal';
            }
            else {
                obj.outcome = 'Normal';
            }

            //complication/remark
            if (row[remarkIdx]){
                obj.remark = row[remarkIdx];
            }

            if (!this.checkRequired(['Id', 'date', 'project', 'chargetype', 'performedby', 'code', 'amount', 'route'], obj, errors, rowIdx)){
                recordMap.drug.push(obj);
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

EHR.DataEntryUtils.registerDataEntryFormButton('BULK_BLOOD_DRAW', {
    text: 'Bulk Blood/Sedation Form',
    name: 'bulkBloodDraw',
    itemId: 'bulkBloodDraw',
    tooltip: 'Click to import using a Bulk Blood/Sedation excel template',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in BULK_BLOOD_DRAW button', panel);

        Ext4.create('ONPRC_EHR.window.BulkBloodDrawWindow', {
            dataEntryPanel: panel
        }).show();
    }
});