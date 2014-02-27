/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.window.CopyTissuesWindow', {
    extend: 'Ext.window.Window',

    initComponent: function(){
        LABKEY.ExtAdapter.apply(this, {
            modal: true,
            closeAction: 'destroy',
            bodyStyle: 'padding: 5px;',
            title: 'Copy Tissues',
            width: 800,
            defaults: {
                border: false
            },
            items: this.getSearchItems(),
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

        this.callParent(arguments);
    },

    getSearchItems: function(){
        return [{
            html: 'This helper allows you to copy a set of tissues previously used in any necropsy.  You can search by project, animal or recipient.  When you search, it will return all distinct sets of tissues matching your criteria, and you can choose which to use in this form.',
            style: 'padding-bottom: 10px;'
        },{
            xtype: 'textfield',
            fieldLabel: 'Animal Id',
            itemId: 'idField',
            width: 400
        },{
            xtype: 'ehr-projectfield',
            fieldLabel: 'Project',
            itemId: 'projectField',
            width: 400
        },{
            xtype: 'ehr-simplecombo',
            fieldLabel: 'Recipient',
            itemId: 'recipientField',
            valueField: 'rowId',
            displayField: 'lastName',
            schemaName: 'onprc_ehr',
            queryName: 'tissue_recipients',
            matchFieldWidth: false,
            sortFields: 'lastName',
            filterArray: [LABKEY.Filter.create('dateDisabled', null, LABKEY.Filter.Types.ISBLANK)],
            width: 400
        },{
            xtype: 'container',
            itemId: 'results',
            defaults: {
                border: false
            }
        }];
    },

    onSubmit: function(){
        var animal = this.down('#idField').getValue();
        var project = this.down('#projectField').getValue();
        var recipient = this.down('#recipientField').getValue();

        if (!animal && !project && !recipient){
            Ext4.Msg.alert('Error', 'Must enter either an animal Id, project or recipient');
            return;
        }

        var filterArray = [];
        if (animal){
            filterArray.push(LABKEY.Filter.create('Id', animal, LABKEY.Filter.Types.EQUAL));
        }

        if (project){
            filterArray.push(LABKEY.Filter.create('project', project, LABKEY.Filter.Types.EQUAL));
        }

        if (recipient){
            filterArray.push(LABKEY.Filter.create('recipient', recipient, LABKEY.Filter.Types.EQUAL));
        }

        Ext4.Msg.wait('Loading...');
        LABKEY.Query.selectRows({
            schemaName: 'study',
            queryName: 'tissueDistributions',
            columns: 'Id,tissue,tissue/meaning,project,project/displayName,project/investigatorId/lastName,recipient,recipient/lastname,dateOnly,parentid',
            requiredVersion: 9.1,
            filterArray: filterArray,
            failure: LDK.Utils.getErrorCallback(),
            success: this.onLoad,
            scope: this
        });
    },

    onLoad: function(results){
        Ext4.Msg.hide();
        if (!results || !results.rows || !results.rows.length){
            Ext4.Msg.alert('No matching records found');
            return;
        }

        //first build a map showing each combination of codes
        var tissueMap = {};
        Ext4.Array.forEach(results.rows, function(r){
            var row = new LDK.SelectRowsRow(r);
            var key = [row.getValue('recipient/lastName'), row.getValue('Id'), row.getValue('dateOnly'), row.getValue('parentid')].join('<>');

            if (!tissueMap[key]){
                tissueMap[key] = {
                    rows: [],
                    orderedCodes: []
                };
            }

            tissueMap[key].rows.push(row);
            if (tissueMap[key].orderedCodes.indexOf(row.getValue('tissue')) == -1){
                tissueMap[key].orderedCodes.push(row.getValue('tissue'));
            }
        }, this);

        console.log(tissueMap);

        //then find all distinct combinations and present these
        var distinctCombinations = {};
        for (var key in tissueMap){
            var obj = tissueMap[key];

            if (!distinctCombinations[obj.orderedCodes.join(';')]){
                distinctCombinations[obj.orderedCodes.join(';')] = {
                    orderedCodes: obj.orderedCodes,
                    rows: []
                }
            }

            distinctCombinations[obj.orderedCodes.join(';')].rows.push(obj);
        }

        console.log(distinctCombinations);
    }
});

EHR.DataEntryUtils.registerGridButton('COPY_TISSUES', function(config){
    config = config || {};

    return Ext4.Object.merge({
        text: 'Copy Previous Tissues',
        itemId: 'copyTissues',
        handler: function(btn){
            var grid = btn.up('gridpanel');
            LDK.Assert.assertNotEmpty('Unable to find gridpanel in COPY_TISSUES button', grid);

            Ext4.create('ONPRC_EHR.window.CopyTissuesWindow', {
                targetStore: grid.store
            }).show();
        }
    }, config);
});