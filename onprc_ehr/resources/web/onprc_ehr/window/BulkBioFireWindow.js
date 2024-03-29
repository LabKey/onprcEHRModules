/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created:  12-27-2022  R. Basa
Ext4.define('ONPRC_EHR.window.BioFireImportWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Import MultiPlex PCR Results From Excel',
            bodyStyle: 'padding: 5px;',
            width: 630,
            defaults: {
                border: false
            },
            items: [{
                html: 'This helper allows you to bulk import Multiplex PCR data, exported as an excel file from the Multiplex PCR software.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download BioFireTemplate_GI_Panel Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/BioFire_Template_GI_Panel.xlsx'
                }

            },{
                xtype: 'ldk-linkbutton',
                text: '[Download BioFireTemplate_BC_Panel Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/BioFire_Template_BC_Panel.xlsx'
                }
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download BioFireTemplate_Respiratory_Panel Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/BioFire_Template_Respiratory_Panel.xlsx'
                }
            },{
                xtype: 'textarea',
                itemId: 'textField',
                height: 300,
                width: 600
            }],
            buttons: [{
                text: 'Submit',
                scope: this,
                handler: this.onSubmit
            },{
                text: 'Close',
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
        var text= this.down('#textField').getValue();
        if (!text){
            Ext4.Msg.alert('Error', 'No file supplied');
            return;
        }

        var parsed = LDK.Utils.CSVToArray(Ext4.String.trim(text), '\t');
        if (!parsed.length || parsed.length < 14){
            Ext4.Msg.alert('Error', 'This file does not have enough lines');
            return;
        }

        //we expect a rectangular table, with 1 column per panel.
        var runsToCreate = [];
        var resultsToCreate = [];



        var remark = Ext4.String.trim(parsed[0][1])  ;
        var category = Ext4.String.trim(parsed[1][1])  ;
        var chargeunit = Ext4.String.trim(parsed[2][1])  ;
        var vet = Ext4.String.trim(parsed[6][1])  ;
        var tissue = Ext4.String.trim(parsed[7][1])  ;

        //Process Service request name
        var name = Ext4.String.trim(parsed[3][1]);
        var procRecIdx = this.labworkSericeStoreStore.findExact('servicename', name);
        var procedureRec = this.labworkSericeStoreStore.getAt(procRecIdx);
        LDK.Assert.assertNotEmpty('Unable to find service request record with name: ' + name + ' in BioFire Window', procedureRec);
        var servicereq = procedureRec.get('servicename');
        var dateRow = parsed[10];
        var idRow = parsed[9];
        var performedby = Ext4.String.trim(parsed[8][1]) ;

        if (dateRow.length != idRow.length){
            Ext4.Msg.alert('Error', 'The length of the first 2 rows do not match.');
            return;
        }
        var errors = [];
        var offset = 4;
        var rowIdx = offset;
        var project = this.resolveProjectByName(Ext4.String.trim(parsed[4][1]), errors,rowIdx );
        var method =   Ext4.String.trim(parsed[5][1] );

         for (var i=1;i<idRow.length;i++){       //Column one
            var runRow = {};
            runRow.Id = idRow[i];
            runRow.date = LDK.ConvertUtils.parseDate(dateRow[i]);
            runRow.objectid = LABKEY.Utils.generateUUID().toUpperCase();
            runRow.servicerequested = servicereq ;
            runRow.project = project ;
            runRow.category = category ;
            runRow.method = method ;
            runRow.vet = vet ;
            runRow.performedby = performedby;
            runRow.remark = remark;
            runRow.tissue = tissue;


            runsToCreate.push(this.runStore.createModel(runRow));

            //then results
            for (var j=11;j<parsed.length;j++){
                var resultRow = {};
                resultRow.Id = runRow.Id;
                resultRow.date = runRow.date;
                resultRow.objectid = LABKEY.Utils.generateUUID().toUpperCase();
                resultRow.runid = runRow.objectid;
                resultRow.remark = remark;

                if (parsed[j].length < i){
                    Ext4.Msg.alert('Error', 'The length result line ' + (j + 1) + ' is less than the header line.');
                    return;
                }
                resultRow.performedby = performedby;
                resultRow.testid = parsed[j][0];
                var result = parsed[j][i];
                if (!Ext4.isEmpty(result)){
                    resultRow.qualresult = Ext4.String.trim(result);
                }


                if (Ext4.isDefined(resultRow.qualresult)){
                    resultsToCreate.push(this.BioFireStore.createModel(resultRow));
                }
                else {
                    console.log('skipping result row: [' + result + ']');
                }
            }
        }

        this.close();


        if (runsToCreate.length){
            this.runStore.add(runsToCreate);
        }

        if (resultsToCreate.length){
            this.BioFireStore.add(resultsToCreate);
        }
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

});

EHR.DataEntryUtils.registerDataEntryFormButton('BIOFIRE_IMPORT', {
        text: 'BioFire Import Template',
        name: 'biofirescan',
        itemId: 'biofirescan',
        tooltip: 'Click to bulk import records from an excel file',
        handler: function(btn){
            var panel = btn.up('ehr-dataentrypanel');
            LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in BioFire_IMPORT button', panel);

            var runStore = panel.storeCollection.getClientStoreByName('Clinpath Runs');
            LDK.Assert.assertNotEmpty('Unable to find clinpath runs store in BIOFIRE_IMPORT button', runStore);

            var BioFireStore = panel.storeCollection.getClientStoreByName('miscTests');
            LDK.Assert.assertNotEmpty('Unable to find BioFire store in BIOFIRE_IMPORT button', BioFireStore);

            Ext4.create('ONPRC_EHR.window.BioFireImportWindow', {
                dataEntryPanel: panel,
                runStore: runStore,
                BioFireStore: BioFireStore
            }).show();
        }
});
