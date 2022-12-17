/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.PathTissuesImportWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Import Pathology Tissue Results From Excel',
            bodyStyle: 'padding: 5px;',
            width: 630,
            defaults: {
                border: false
            },
            items: [{
                html: 'This helper allows you to bulk import Path_Tissues data, exported as an excel file from the Path Tissues software.',
                style: 'padding-bottom: 10px;'
            },{
                xtype: 'ldk-linkbutton',
                text: '[Download Pathology Tissues Template]',
                scope: this,
                style: 'margin-bottom: 10px;',
                handler: function(){
                    window.location = LABKEY.contextPath + '/onprc_ehr/templates/PathologyTissues_Panel.xlsx'
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

        //Process Encounters table
        var recipient = parsed[3][1];
        var dateRow = parsed[5][1];
        var idRow = parsed[4][1];



        var errors = [];
        var offset = 1;
        var rowIdx = offset;
        var project = this.resolveProjectByName(Ext4.String.trim(parsed[1][1]), errors,rowIdx );
        var billingproject = this.resolveProjectByName(Ext4.String.trim(parsed[2][1]), errors,rowIdx );


        // for (var i=1;i<idRow.length;i++){       //Column one
            var runRow = {};
            runRow.Id = idRow;
            runRow.date = LDK.ConvertUtils.parseDate(dateRow);
            runRow.objectid = LABKEY.Utils.generateUUID().toUpperCase();
            runRow.project = project ;
            runRow.billingproject = project ;


            runsToCreate.push(this.runStore.createModel(runRow));

                    //then results
                    for (var j=6;j<parsed.length;j++){
                        var resultRow = {};
                        resultRow.Id = runRow.Id;
                        resultRow.date = runRow.date;
                        resultRow.project = runRow.project;
                        resultRow.recipient = recipient;
                        resultRow.objectid = LABKEY.Utils.generateUUID().toUpperCase();



                        resultRow.sampletype = parsed[j][2];
                        resultRow.tissue = parsed[j][4];
                        var comments = parsed[j][5];
                        if (!Ext4.isEmpty(comments)){
                            resultRow.remark = Ext4.String.trim(comments);
                        }

                        if (Ext4.isDefined(resultRow.tissue)){
                            resultsToCreate.push(this.TissuesStore.createModel(resultRow));
                        }
                        else {
                            console.log('skipping result row: [' + result + ']');
                        }

                   }


        this.close();


        if (runsToCreate.length){
            this.runStore.add(runsToCreate);
        }

        if (resultsToCreate.length){
            this.TissuesStore.add(resultsToCreate);
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

EHR.DataEntryUtils.registerDataEntryFormButton('Tissues_IMPORT', {
    text: 'Pathology Tissues Import Template',
    name: 'pathtissuesscan',
    itemId: 'pathtissuesscan',
    tooltip: 'Click to bulk import records from an excel file',
    handler: function(btn){
        var panel = btn.up('ehr-dataentrypanel');
        LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in Tissues_IMPORT button', panel);

        var runStore = panel.storeCollection.getClientStoreByName('encounters');
        LDK.Assert.assertNotEmpty('Unable to find Encounters runs store in Tissues_IMPORT button', runStore);

        var TissuesStore = panel.storeCollection.getClientStoreByName('tissueDistributions');
        LDK.Assert.assertNotEmpty('Unable to find Tissue Distribution store in Tissues_IMPORT button', TissuesStore);

        Ext4.create('ONPRC_EHR.window.PathTissuesImportWindow', {
            dataEntryPanel: panel,
            runStore: runStore,
            TissuesStore: TissuesStore
        }).show();
    }
});
