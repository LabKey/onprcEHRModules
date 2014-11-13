/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.IStatImportWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        Ext4.apply(this, {
            modal: true,
            closeAction: 'destroy',
            title: 'Import iStat Results From Excel',
            bodyStyle: 'padding: 5px;',
            width: 630,
            defaults: {
                border: false
            },
            items: [{
                html: 'This helper allows you to bulk import iSTAT data, exported as an excel file from the iSTAT software.',
                style: 'padding-bottom: 10px;'
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

        var dateRow = parsed[0];
        var idRow = parsed[1];
        if (dateRow.length != idRow.length){
            Ext4.Msg.alert('Error', 'The length of the first 2 rows do not match.');
            return;
        }

        for (var i=1;i<idRow.length;i++){
            var runRow = {};
            runRow.Id = idRow[i];
            runRow.date = LDK.ConvertUtils.parseDate(dateRow[i]);
            runRow.objectid = LABKEY.Utils.generateUUID().toUpperCase();
            runRow.servicerequested = 'iSTAT';
            runsToCreate.push(this.runStore.createModel(runRow));

            //then results
            for (var j=11;j<parsed.length;j++){
                var resultRow = {};
                resultRow.Id = runRow.Id;
                resultRow.date = runRow.date;
                resultRow.objectid = LABKEY.Utils.generateUUID().toUpperCase();
                resultRow.runid = runRow.objectid;

                if (parsed[j].length < i){
                    Ext4.Msg.alert('Error', 'The length result line ' + (j + 1) + ' is less than the header line.');
                    return;
                }
                resultRow.testid = parsed[j][0];
                var result = parsed[j][i];
                if (!Ext4.isEmpty(result)){
                    result = Ext4.String.trim(result);
                }

                if (Ext4.isEmpty(result) || '<>' == result || '***' == result){
                    //skip
                }
                else if (Ext4.isNumeric(result)){
                    resultRow.result = result;
                }
                else if (result.indexOf('<') == 0 || result.indexOf('>') == 0){
                    resultRow.resultOORIndicator = result[0];
                    resultRow.result = result.substr(1);
                }

                if (Ext4.isDefined(resultRow.result)){
                    resultsToCreate.push(this.iStatStore.createModel(resultRow));
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
            this.iStatStore.add(resultsToCreate);
        }
    }
});

EHR.DataEntryUtils.registerGridButton('ISTAT_IMPORT', function(config){
    return Ext4.Object.merge({
        text: 'Add From Excel',
        xtype: 'button',
        tooltip: 'Click to bulk import records from an excel file',
        handler: function(btn){
            var grid = btn.up('grid');
            LDK.Assert.assertNotEmpty('Unable to find grid in ISTAT_IMPORT button', grid);

            var panel = grid.up('ehr-dataentrypanel');
            LDK.Assert.assertNotEmpty('Unable to find dataEntryPanel in ISTAT_IMPORT button', panel);

            var runStore = panel.storeCollection.getClientStoreByName('Clinpath Runs');
            LDK.Assert.assertNotEmpty('Unable to find clinpath runs store in ISTAT_IMPORT button', runStore);

            var iStatStore = panel.storeCollection.getClientStoreByName('iStat');
            LDK.Assert.assertNotEmpty('Unable to find iStat store in ISTAT_IMPORT button', iStatStore);

            Ext4.create('ONPRC_EHR.window.IStatImportWindow', {
                runStore: runStore,
                iStatStore: iStatStore
            }).show();
        }
    });
});
