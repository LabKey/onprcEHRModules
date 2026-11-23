/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created:  10-29-2026  R. Basa
Ext4.define('ONPRC_EHR.window.Bulk_CBC_AcquisitionedAnimalsWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Import CBC Acquisition Animals Results From Excel',
            bodyStyle: 'padding: 5px;',
            width: 630,
            defaults: {
                border: false
            },
            items: [{
                html : 'This allows you to import record using the CBC Acquisitioned Animals excel form.  To import, cut/paste the contents of the excel file (Ctl + A is a good way to select all) into the box below and hit submit.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download CBC Acquisition Animals Results Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/CBC Acquisition Animals Results_Panel.xlsx'
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


        var category = Ext4.String.trim(parsed[5][1])  ;
        var chargeunit = Ext4.String.trim(parsed[2][1])  ;
        var vet = Ext4.String.trim(parsed[3][1])  ;

        //Process Service request name
        var name = Ext4.String.trim(parsed[1][1]);  //service request name
        var procRecIdx = this.labworkSericeStoreStore.findExact('servicename', name);
        var procedureRec = this.labworkSericeStoreStore.getAt(procRecIdx);
        LDK.Assert.assertNotEmpty('Unable to find service request record with name: ' + name + ' in BioFire Window', procedureRec);
        var servicereq = procedureRec.get('servicename');
        var performedby = Ext4.String.trim(parsed[4][1]) ;

        if (dateRow.length != idRow.length){
            Ext4.Msg.alert('Error', 'The length of the first 2 rows do not match.');
            return;
        }
        var errors = [];
        var offset = 6;
        var rowIdx = offset;
        var project = this.resolveProjectByName(Ext4.String.trim(parsed[0][1]), errors,rowIdx );


        for (var i=1;i<idRow.length;i++){       //Column one
            var runRow = {};
            runRow.Id = idRow[i];
            runRow.date = LDK.ConvertUtils.parseDate(dateRow[i]);
            runRow.objectid = LABKEY.Utils.generateUUID().toUpperCase();
            runRow.servicerequested = servicereq ;
            runRow.project = project ;
            runRow.category = category ;
            runRow.vet = vet ;
            runRow.performedby = performedby;


            runsToCreate.push(this.runStore.createModel(runRow));

            //panel lab results
            for (var j=2;j<parsed.length;j++){
                for (var k=2;j< 21;k++) {
                    var resultRow = {};
                    resultRow.Id = runRow.Id;
                    resultRow.date = runRow.date;
                    resultRow.objectid = LABKEY.Utils.generateUUID().toUpperCase();
                    resultRow.runid = runRow.objectid;

                    if (parsed[j].length < i) {
                        Ext4.Msg.alert('Error', 'The length result line ' + (j + 1) + ' is less than the header line.');
                        return;
                    }
                    resultRow.performedby = performedby;
                    resultRow.testid = parsed[j - 1][k];
                    resultRow.result = parsed[j][k];

                    if (Ext4.isDefined(resultRow.qualresult)) {
                        resultsToCreate.push(this.BioFireStore.createModel(resultRow));
                    } else {
                        console.log('skipping result row: [' + result + ']');
                    }
                }
            }
        }

        this.close();


        if (runsToCreate.length){
            this.runStore.add(runsToCreate);
        }

        if (resultsToCreate.length){
            this.PanelStore.add(resultsToCreate);
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

EHR.DataEntryUtils.registerDataEntryFormButton('CBC_Acquisitioned_IMPORT', {
    text: 'CBC Acqiusitioned Import Template',
    name: 'CBC_Acquisition_scan',
    itemId: 'cbcAcqiuisitonescan',
    tooltip: 'Click to bulk import records from an excel file',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in CBC_Acquisitioned_IMPOR', panel);

        var runStore = panel.storeCollection.getClientStoreByName('Clinpath Runs');
        LDK.Assert.assertNotEmpty('Unable to find clinpath runs store in CBC_Acquisitioned_IMPOR', runStore);

        var PanelStore = panel.storeCollection.getClientStoreByName('HematologyResults');
        LDK.Assert.assertNotEmpty('Unable to find BioFire store in CBC_Acquisitioned_IMPOR button', PanelStore);

        Ext4.create('ONPRC_EHR.window.BioFireImportWindow', {
            dataEntryPanel: panel,
            runStore: runStore,
            PanelStore: PanelStore
        }).show();
    }
});
